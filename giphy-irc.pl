#!/usr/bin/env perl
#
# Giphy API Image Search Retriever
#
# ---
#
# Usage:
#
#    giphy.pl <search phrase>
#
# Example:
#
#    giphy.pl funny cats
#
# ---
#
# See the Giphy API github page for more info.
#
# https://github.com/Giphy/GiphyAPI
#

use strict;
use warnings;
use JSON;
use LWP::Simple;
use URI::Encode qw(uri_encode uri_decode);
use Irssi;

#
# Globals
#
use vars qw($VERSION %IRSSI $DEBUG_MODE $GIPHY_URL $PUBLIC_API_KEY $LIMIT_NUM);
$VERSION = '1.0';
%IRSSI = (
    authors     => 'Robert Bisewski',
    contact     => 'contact@ibiscybernetics.com',
    name        => 'Giphy Search',
    description => 'Obtains a giphy image based on the search criteria',
    license     => 'Public Domain',
    url         => 'https://gitlab.com/giphy-perl/',
    changed     => 'Fri May 19 14:05:21 CDT 2017',
);
$DEBUG_MODE     = 0;
$GIPHY_URL      = "http://api.giphy.com/v1/gifs/search?";
$PUBLIC_API_KEY = "api_key=dc6zaTOxFJmzC";
$LIMIT_NUM      = "1";

#
# Print script usage.
#
sub print_usage {
    my ($server, $target) = @_;
    $server->command("msg $target Usage: !giphy <search terms>");
}

#
# Obtain an image using the giphy API.
#
sub get_giphy_image {

    # Params
    my ($server, $msg, $nick, $address, $target) = @_;

    # Param handling
    if (!$server || !defined $msg || !defined $nick || length($nick) < 1
      || !defined $address || length($address) < 1 || !defined $target
      || length($target) < 1) {
        Irssi::print "Invalid message input.";
        return 1;
    }

    # Lower case the search terms, and break them up into an array.
    $msg = lc($msg);
    my @msg_parts = split($msg);

    # Exit if unable to split.
    if (!@msg_parts) {
        Irssi::print "Unable to split public message content.";
        return 1;
    }

    # Check that the user actually typed `!giphy`, else exit.
    if ($msg_parts[0] != "!giphy") {
        if ($DEBUG_MODE) {
            Irssi::print "Giphy not declared.";
        }
        return 0;
    }

    # Obtain the search terms.
    my $search_terms = "";
    for (@msg_parts) {
         if (!$_) {
         } elsif ($search_terms eq "") {
             $search_terms = uri_encode($_);
         } else {
             $search_terms = $search_terms . "+" . uri_encode($_);
         }
    }

    # If the search term is blank, go ahead and return 1.
    if (length($search_terms) < 1) {
        print_usage();
        return 1;
    }

    # If debug mode, print out the search terms section. 
    if ($DEBUG_MODE) {
        Irssi::print "Search terms: " . $search_terms . "\n";
    }

    # Assemble the URL.
    my $encoded_url = $GIPHY_URL . $PUBLIC_API_KEY . "&limit=" .
      $LIMIT_NUM . "&q=" . $search_terms;

    # Grab the page with the requested search item.
    my $content = get($encoded_url);

    # Ensure this actually got a result.
    if (length($content) < 1) {
        Irssi::print "Improper response recieved. Terminating...";
        return 1;
    }

    # If debug more, go ahead and print out the JSON data.
    if ($DEBUG_MODE) {
        Irssi::print "JSON Data: \n";
        Irssi::print "---- START ----\n";
        Irssi::print $content . "\n";
	Irssi::print "---- END ----\n";
    }

    # Attempt to convert this to an internal JSON object.
    my $json = JSON->new->allow_nonref; 

    # Ensure the JSON object was started correctly.
    if (!$json) {
       Irssi::print "Improperly formed JSON. Terminating...";
       return 1;
    }

    # Attempt to decode the given json content data.
    my $decoded_json = $json->decode($content);

    # Sanity check, make sure that worked.
    if (!$decoded_json) {
        Irssi::print "Unable to decode JSON. Terminating...";
        return 1;
    }

    # Grab the data array.
    my @json_data_root = %$decoded_json{"data"};

    # Grab the first element of that object.
    my @json_data_array = $json_data_root[1];

    # If certain elements are not available, end the program since the
    # giphy API has likely changed.
    if (!$json_data_array[0]) {
        Irssi::print "Broken JSON detected. Terminating...";
        return 1;
    } elsif (!$json_data_array[0][0]) {
        Irssi::print "Broken JSON detected. Terminating...";
        return 1;
    } elsif (!$json_data_array[0][0]{"images"}) {
        Irssi::print "Broken JSON detected. Terminating...";
        return 1;
    } elsif (!$json_data_array[0][0]{"images"}{"original"}) {
        Irssi::print "Broken JSON detected. Terminating...";
        return 1;
    } elsif (!$json_data_array[0][0]{"images"}{"original"}{"url"}) {
        Irssi::print "Broken JSON detected. Terminating...";
        return 1;
    }

    # Grab the response...
    my $response = $json_data_array[0][0]{"images"}{"original"}{"url"};

    # All is well, so return 0.
    return 0;
}

################################################
Irssi::signal_add('message public', 'get_giphy_image');