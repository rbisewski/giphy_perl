# giphy-perl - a perl-based way of interacting with Giphy

The goal of this script was to allow easy access to a certain Slack
feature, specifically, silly gifs via Giphy. A number of existing scripts
were not written in perl, hence this was created.

If you want to learn more about Giphy, see the following link:

https://giphy.com

Or the github repo readme if you plan on using their API:

https://github.com/Giphy/GiphyAPI 


# Requirements

Perl 5 is needed to make this work, as well as the following perl modules:

* JSON
* LWP
* URI
* URI::Encode


# Installation

Simply use this as-is in the commandline, by setting the "$is_terminal"
variable to 1.


# Running sighte

Usage:

    perl giphy.pl <search terms>

For example:

    perl giphy.pl funny cat

See the main file itself for more details.


# Authors

This was forked and adapted to perl5 by Robert Bisewski at Ibis
Cybernetics. For more information, contact:

* Website -> www.ibiscybernetics.com

* Email -> contact@ibiscybernetics.com

The original author was Michael Stathers, who wrote it in python.
For more information, consider contacting him at:

* Website -> www.stathers.net
