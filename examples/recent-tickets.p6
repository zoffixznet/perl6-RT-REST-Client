use lib <lib>;
use RT::REST::Client;

my RT::REST::Client $rt .= new: :user<foo>, :pass:<bar>;

say $rt.search;
