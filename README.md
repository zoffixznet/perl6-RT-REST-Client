[![Build Status](https://travis-ci.org/zoffixznet/perl6-RT-REST-Client.svg)](https://travis-ci.org/zoffixznet/perl6-RT-REST-Client)

# NAME

RT::REST::Client - Use Request Tracker's (RT) REST client interface

# SYNOPSIS

```perl6

my RT::REST::Client $rt .= new: :login<rt@example.com>, :pass<secr3t>;
printf '#%s %s %s %s', .id, .tags, .subject, .link
    for $rt.search: since => Date.today.earlier: :1week;
```

# EARLY RELEASE

Currently only search feature is supported. More features will be added as
needed, upon request.

# LOGIN CREDENTIALS

You need to go to user preferences and set up your CLI password for your
credentials to work via REST API. For Perl 6's RT, go to
[https://rt.perl.org/User/Prefs.html](https://rt.perl.org/User/Prefs.html)
and the CLI Password section should be on the right side of the page.

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-RT-REST-Client

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-RT-REST-Client/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
