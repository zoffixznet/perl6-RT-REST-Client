unit class RT::REST::Client;
use HTTP::UserAgent;
use URI;
use URI::Escape;

has $!user;
has $!pass;
has $!rt-url;
has $!ticket-url;
has $!ua = HTTP::UserAgent.new;

submethod BUILD (:$!user!, :$!pass!, :$!rt-url = 'https://rt.perl.org/REST/1.0') {
    $!ticket-url = do given URI.new: $!rt-url {
        [~] .scheme, '://', .host, (':' ~ .port if .port != 80|443),
            '/Ticket/Display.html?id=';
    }
}

my grammar RT::REST::Client::Tickets {
    rule TOP { <header>
        [
            $<no-results>='No matching results.'
            | [<ticket> ]+
        ]
    }
    token header { 'RT/' [\d+]**3 % '.' \s+ '200 Ok' }
    token ticket { $<id>=\d+ ':' <.ws> <tag>* <.ws>? $<subject>=\N+ }
    token tag { '[' ~ ']' .+? }
}

my class RT::REST::Client::Ticket {
    has $.id;
    has $.tags;
    has $.subject;
    has $.url;
}

my class TicketsActions {
    has $.ticket-url;

    method TOP ($/) {
        if $<no-results> {
            make [];
            return;
        }
        my @tickets;
        for $<ticket> -> $ticket {
            @tickets.push: RT::REST::Client::Ticket.new:
                id       => +.<id>,
                tags     => .<tag>.list,
                subject  => ~.<subject>,
                url      => $!ticket-url ~ +.<id> ~ '#ticket-history',
            given $ticket;
        }
        make @tickets;
    }
}

method search (
    Dateish :$after, Dateish :$before, Str :$queue = 'perl6',
    :$status = [], :$not-status is copy = [],
) {
    $not-status = ('resolved', 'rejected')
        unless $status or $not-status;

    my $cond = join " AND ",
        ("Created >= '$after.yyyy-mm-dd()'"  if $after ),
        ("Created < '$before.yyyy-mm-dd()'"  if $before),
        ( "(" ~ $status.map({"Status = '$_'"}).join(' OR ')  ~ ")" if $status ),
        $not-status.map({"Status != '$_'"});

    my $url = "$!rt-url/search/ticket?user=$!user&pass=$!pass&orderby=-Created"
        ~ "&query=" ~ uri-escape("Queue = '$queue' AND ($cond)");

    my $s = $!ua.get: $url;
    fail $s.status-line unless $s.is-success;

    return RT::REST::Client::Tickets.parse(
        $s.content, actions => TicketsActions.new: :$!ticket-url
    ).made // fail 'Failed to parse response which was: ' ~ $s.content;
}
