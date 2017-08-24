# giphy-perl - a perl-based way of interacting with Giphy

The goal of this script is to allow easy access to silly gifs via Giphy,
for use in a standard irc environment. A number of existing scripts were
not written in perl, hence this was created.

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

Note that this has only been tested on Ubuntu and Arch Linux, but in theory
it will work in any OS or distro that has the above perl modules installed.
Feel free to send me an email if this is not the case for your system and I
will consider looking into it.


# Installation

Simply use this as-is in the commandline, by setting the "$is_terminal"
variable to 1.


# Running giphy-perl 

Usage:

    perl giphy.pl <search terms>

For example:

    perl giphy.pl funny cat

See the main file itself for more details.


# Authors

This was forked and adapted to perl by Robert Bisewski at Ibis
Cybernetics. For more information, contact:

* Website -> www.ibiscybernetics.com

* Email -> contact@ibiscybernetics.com

The original author was Michael Stathers, who wrote it in python.
For more information, consider contacting him at:

* Website -> www.stathers.net
