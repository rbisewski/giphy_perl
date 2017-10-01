#!/usr/bin/env perl
#
# Giphy API Image Search Retriever
#
# ---
#
# Usage:
#
#    .giphy <search phrase>
#
# Example:
#
#    .giphy funny cats
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
    changed     => 'Thu June 1 14:05:21 CDT 2017',
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
    $server->command("msg $target Usage: .giphy <search terms>");
}

#
# Handle the case when dealing with public messages.
#
sub sig_msg_pub {
    my ($server, $msg, $nick, $address, $target) = @_;

    # Param handling
    if (!$server || !defined $msg || length($msg) < 1 || !defined $nick
      || length($nick) < 1 || !defined $address || length($address) < 1
      || !defined $target || length($target) < 1) {
        Irssi::print "sig_msg_pub() --> Invalid message input.";
        return 1;
    }

    # If not giphy then leave immediately.
    if ($msg !~ /^(?:!|\.)giphy /) {
        return 0;
    }

    # attempt to grab a giphy link
    get_giphy_image($server, $msg, $target);
}

#
# Handle the case when dealing with one's own input.
#
sub sig_msg_own_pub {
    my ($server, $msg, $target) = @_;

    # Param handling
    if (!$server || !defined $msg || length($msg) < 1 || !defined $target
      || length($target) < 1) {
        Irssi::print "sig_msg_own_pub() --> Invalid message input.";
        return 1;
    }

    # If not giphy then leave immediately.
    if ($msg !~ /^(?:!|\.)giphy /) {
        return 0;
    }

    # Fixes message ordering
    Irssi::signal_continue($server, $msg, $target);

    # attempt to grab a giphy link
    get_giphy_image($server, $msg, $target);
}

#
# Obtain an image using the giphy API.
#
sub get_giphy_image {
    my ($server, $msg, $target) = @_;

    # Param handling
    if (!$server || !defined $msg || !defined $target
      || length($target) < 1) {
        Irssi::print "get_giphy_image() --> Invalid message input.";
        return 1;
    }

    # Debug, print message content.
    if ($DEBUG_MODE) {
        Irssi::print "Message was: $msg";
    }

    # Lower case the search terms, and break them up into an array.
    $msg = lc($msg);
    my @msg_parts = split / /, $msg;

    # Exit if unable to split.
    if (!@msg_parts) {
        Irssi::print "Unable to split public message content.";
        return 1;
    }

    # Check that the user actually typed `!giphy`, else exit.
    if ($msg_parts[0] !~ /^(?:!|\.)giphy$/) {
        if ($DEBUG_MODE) {
            Irssi::print "Giphy not declared.";
        }
        return 0;
    }

    # Obtain the search terms.
    my $term_counter = 0;
    my $search_terms = "";
    for (@msg_parts) {

         # Handle the case of blank or initial values.
         if (!$_) {
             next;
         } elsif ($term_counter == 0) {
             $term_counter++;
             next;
         }

         # Append search terms...
         if ($search_terms eq "") {
             $search_terms = uri_encode($_);
         } else {
             $search_terms = $search_terms . "+" . uri_encode($_);
         }

         # Increment the term counter
         $term_counter++;
    }

    # If the search term is blank, go ahead and return 1.
    if (length($search_terms) < 1) {
        print_usage($server, $target);
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
    #
    # This checking is a little less robust now that we output on no
    # result.
    if (!$json_data_array[0]) {
        Irssi::print "Broken JSON detected. Terminating...";
        return 1;
    }

    my $response;
    if ($json_data_array[0][0]{"embed_url"}) {
        # Grab the response...
        $response = $json_data_array[0][0]{"embed_url"};
    } else {
        $response = "giphy: No results found.";
    }

    # Ensure the response is actually valid.
    if (length($response) < 1) {
        Irssi::print "Invalid response detected. Terminating...";
        return 1;
    }

    # Out the response to the public message channel.
    $server->command("action $target $response");

    # All is well, so return 0.
    return 0;
}

############################################################
Irssi::signal_add('message public', 'sig_msg_pub');
Irssi::signal_add('message own_public', 'sig_msg_own_pub');
