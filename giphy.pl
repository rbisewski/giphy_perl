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

# Globals
my $debug_mode     = 0;
my $is_terminal    = 1;
my $giphy_url      = "http://api.giphy.com/v1/gifs/search?";
my $public_api_key = "api_key=dc6zaTOxFJmzC";
my $limit_num      = "1";

#
# Program main
#
sub main() {

    # Input validation
    if ($#ARGV < 1) {
        print "No search terms were provided. Exiting...\n";
        return 1;
    }

    # Obtain the search terms.
    my $search_terms = "";
    for (@ARGV) {
         if ($search_terms eq "") {
             $search_terms = uri_encode($_);
         } else {
             $search_terms = $search_terms . "+" . uri_encode($_);
         }
    }

    # If the search term is blank, go ahead and return 1.
    if (length($search_terms) < 1) {
        return 1;
    }

    # If debug mode, print out the search terms section. 
    if ($debug_mode) {
        print "Search terms: " . $search_terms . "\n";
    }

    # Assemble the URL.
    my $encoded_url = $giphy_url . $public_api_key . "&limit=" .
      $limit_num . "&q=" . $search_terms;

    # Grab the page with the requested search item.
    my $content = get($encoded_url);

    # Ensure this actually got a result.
    if (length($content) < 1) {
        return 1;
    }

    # If debug more, go ahead and print out the JSON data.
    if ($debug_mode) {
        print "JSON Data: \n";
        print "---- START ----\n";
        print $content . "\n";
	print "---- END ----\n";
    }

    # Attempt to convert this to an internal JSON object.
    my $json = JSON->new->allow_nonref; 

    # Ensure the JSON object was started correctly.
    if (!$json) {
       return 1;
    }

    # Attempt to decode the given json content data.
    my $decoded_json = $json->decode($content);

    # Sanity check, make sure that worked.
    if (!$decoded_json) {
        return 1;
    }

    # Grab the data array.
    my @json_data_root = %$decoded_json{"data"};

    # Grab the first element of that object.
    my @json_data_array = $json_data_root[1];

    # If certain elements are not available, end the program since the
    # giphy API has likely changed.
    if (!$json_data_array[0]) {
        return 1;
    } elsif (!$json_data_array[0][0]) {
        return 1;
    } elsif (!$json_data_array[0][0]{"images"}) {
        return 1;
    } elsif (!$json_data_array[0][0]{"images"}{"original"}) {
        return 1;
    } elsif (!$json_data_array[0][0]{"images"}{"original"}{"url"}) {
        return 1;
    }

    # Print the URL to stdout.
    print $json_data_array[0][0]{"images"}{"original"}{"url"};

    # If this is a terminal, go ahead and print out a newline.
    if ($is_terminal) {
        print "\n";
    }

    # All is well, so return 0.
    return 0;
}

#############
exit(main());
