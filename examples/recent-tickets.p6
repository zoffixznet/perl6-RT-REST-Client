use lib <lib>;
use RT::REST::Client;

my RT::REST::Client $rt .= new: :user<foo>, :pass<bar>;

my @status = <boo bar ber boor>;

say $rt.search:
    :since(Date.today.earlier: :week)
    :before(Date.today.earlier: :2weeks)
    :@status
    :not-status<stale>;

say now - INIT now;
