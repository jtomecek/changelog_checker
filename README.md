# Website Update Notifier Script

This Perl script automatically fetches updates from specified websites and sends notifications about new posts to a Slack channel. It's designed to monitor changelogs or blog updates, making it easier to stay informed about the latest changes or posts.

## Features

- Fetch updates from multiple websites
- Send notifications to a Slack channel
- Configurable to add more sites or change Slack channels
- Option to run in database-only mode for collecting updates without sending notifications

## Requirements

- Perl 5
- Required Perl modules: `LWP::UserAgent`, `HTML::TreeBuilder`, `JSON`, and `Getopt::Long`
- Slack webhook URL for the channel where notifications will be sent

## Installation

1. Ensure Perl is installed on your system. You can check by running `perl -v` in your terminal.
2. Install the required Perl modules. You can install these using CPAN:

    ```shell
    cpan install LWP::UserAgent HTML::TreeBuilder JSON Getopt::Long
    ```

3. Clone this repository or download the script to your local machine.

## Usage

To run the script, you need to provide the Slack webhook URL as a command-line argument or opt for the database-only mode. Here are the usage options:

- To send updates to Slack:

    ```shell
    perl changelog_checker.pl --slack-webhook-url=YOUR_SLACK_WEBHOOK_URL
    ```

- To update the database without sending notifications to Slack (Database-Only Mode):

    ```shell
    perl changelog_checker.pl --generate-db-only
    ```

Replace `changelog_checker.pl` with the actual name of the script file.

## Configuring Sites

The script is pre-configured for certain sites but can be easily adjusted by editing the `@sites` array in the script. Each site configuration requires a URL, a file for storing sent posts, and the HTML tag and class for identifying new posts.


