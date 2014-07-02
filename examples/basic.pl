#!/usr/bin/env perl

use strictures;
use feature ':5.14';

use FindBin qw($Bin);
use lib "$Bin/../lib";

use WebService::Toggl;

main: {
    die 'Need TOGGL_API_KEY envvar set!' unless ($ENV{TOGGL_API_KEY});

    my $toggl = WebService::Toggl->new({api_key => $ENV{TOGGL_API_KEY}});

    my $me = $toggl->me;
    say "Me: " . $me->fullname . " <" . $me->email . ">:";

    say "My Workspaces:";
    for my $ws ($me->workspaces->all) {
        say "  " . $ws->name . " (" . $ws->id . ")";
    }

    say "My Projects:";
    for my $project ($me->projects->all) {
        say "  " . $project->name . " (" . $project->id . ")";
    }

    say "My Time Entries:";
    for my $entry ($me->time_entries->all) {
        say "  " . $entry->description . " (" . $entry->id . ")";
    }

    say "My Tags:";
    for my $tag ($me->tags->all) {
        say "  " . $tag->name . " (" . $tag->id . ")";
    }

    say "My Clients:";
    for my $client ($me->clients->all) {
        say "  " . $client->name . " (" . $client->id . ")";
    }


}

__END__
