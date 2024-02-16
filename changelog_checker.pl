#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
use HTML::TreeBuilder;
use JSON;

# Check for the Slack webhook URL passed as a command line argument
my $slack_webhook_url = $ARGV[0] or die "Usage: $0 slack_webhook_url\n";

# General configurations
my $user_agent_string = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3';

# Site-specific configurations
my @sites = (
    {
        url_to_fetch => 'https://developers.gorgias.com/changelog',
        sent_posts_file => 'sent_posts_gorgias.txt',
        post_selector => {
            _tag => 'h1',
            class => qr/^ChangelogPost_title/
        }
    },
    {
        url_to_fetch => 'https://developers.hubspot.com/changelog',
        sent_posts_file => 'sent_posts_hubspot.txt',
        post_selector => {
            _tag => 'h3',
            class => undef # No class defined
        }
    }
);

foreach my $site (@sites) {
    process_site($site, $user_agent_string, $slack_webhook_url);
}

sub process_site {
    my ($config, $user_agent, $webhook_url) = @_;

    # Read sent posts from file
    my %sent_posts;
    if (-e $config->{sent_posts_file}) {
        open my $file, '<', $config->{sent_posts_file} or die "Could not open file '$config->{sent_posts_file}': $!";
        while (my $line = <$file>) {
            chomp $line;
            $sent_posts{$line} = 1;
        }
        close $file;
    }

    # Create a user agent
    my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 });
    $ua->agent($user_agent);

    # Fetch the content of the webpage
    my $response = $ua->get($config->{url_to_fetch});

    if ($response->is_success) {
        my $tree = HTML::TreeBuilder->new_from_content($response->decoded_content);
        
        my @posts;
        if (defined $config->{post_selector}->{class}) {
            @posts = $tree->look_down(_tag => $config->{post_selector}->{_tag}, class => $config->{post_selector}->{class});
        } else {
            @posts = $tree->look_down(_tag => $config->{post_selector}->{_tag});
        }

        for my $post (@posts) {
            my $post_title = $post->as_text;

            unless ($sent_posts{$post_title}) {
                my $payload = encode_json({
                    text => "New Post: $post_title\n$config->{url_to_fetch}",
                });
                
                my $req = HTTP::Request->new('POST', $webhook_url);
                $req->header('Content-Type' => 'application/json');
                $req->content($payload);

                my $slack_response = $ua->request($req);

                if ($slack_response->is_success) {
                    print "Post successfully sent to Slack: $post_title\n";
                    open my $file, '>>', $config->{sent_posts_file} or die "Could not open file '$config->{sent_posts_file}': $!";
                    print $file "$post_title\n";
                    close $file;
                } else {
                    print "Failed to send post to Slack: ", $slack_response->status_line, "\n";
                }
            } else {
                print "Post has already been sent: $post_title\n";
            }
        }
    } else {
        print "Failed to fetch the webpage: ", $response->status_line, "\n";
    }
}
