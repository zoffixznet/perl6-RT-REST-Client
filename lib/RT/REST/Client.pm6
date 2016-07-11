unit class RT::REST::Client;
use HTTP::UserAgent;
use URI;
use URI::Escape;

has $!user;
has $!pass;
has $!rt;
has $!ticket-url;

submethod BUILD (:$!user!, :$!pass!, :$!rt = 'https://rt.perl.org/REST/1.0') {
    $!ticket-url = do given URI.new: $!rt {
        [~] .scheme, '://', .host, (':' ~ .port if .port != 80|443),
            '/Ticket/Display.html?id=';
    }
}

my grammar RT::REST::Client::Tickets {
    rule TOP { <header> [<ticket> ]+ }
    token header { 'RT/' [\d+]**3 % '.' \s+ '200 Ok' }
    token ticket { $<id>=\d+ ':' <.ws> <tag>* <.ws> $<subject>=\N+ }
    token tag { '[' ~ ']' \w+ }
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
        my @tickets;
        for $<ticket> -> $ticket {
            @tickets.push: RT::REST::Client::Ticket.new:
                id       => +.<id>,
                tags     => .<tag>.join(' '),
                subject  => ~.<subject>,
                url      => $!ticket-url ~ +.<id> ~ '#ticket-history',
            given $ticket;
        }
        make @tickets;
    }
}

method search (
    Dateish :$since, Dateish :$before, Str :$queue = 'perl6',
    :$status, :$not-status,
) {
    $not-status = ('resolved', 'rejected')
        unless $status or $not-status;

    my $cond = join " AND ",
        ("Created >= '$since.yyyy-mm-dd()'"  if $since ),
        ("Created <= '$before.yyyy-mm-dd()'" if $before),
        $status.map({"Status = '$_'"}),
        $not-status.map({"Status != '$_'"});
    $cond;
    # my $url = "$!server/search/ticket?user=$!user&pass=$!pass&orderby=-Created"
    #     ~ "&query=" ~ uri-escape("Queue = '$queue' AND ($cond)");
    #
    # my $s = $.ua.get: $url;
    # fail $s.status-line unless $s.is-success;
    # Tickets.parse(
    #     $s.content, actions => TicketsActions.new: :$!ticket-url
    # ).made;
}
