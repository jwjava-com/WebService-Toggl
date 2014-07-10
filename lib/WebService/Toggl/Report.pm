package WebService::Toggl::Report;

use DateTime;
use Sub::Quote qw(quote_sub);

use Moo::Role;
with 'WebService::Toggl::Role::Base';

has base_url => (is => 'ro', default => '/reports/api/v2');

has my_url   => (is => 'ro', lazy => 1, builder => 1);
sub _build_my_url { $_[0]->base_url . '/' . $_[0]->api_path }

requires 'api_path';

has raw => (is => 'ro', lazy => 1, builder => 1);
sub _build_raw {
    my ($self) = @_;
    my $response = $self->api_get($self->my_url, $self->req_params);
    return $response->data;
}
sub _req_params { [qw(workspace_id since until)] }
sub req_params {
    my ($self) = @_;
    return {
        (map {$_ => $_[0]->$_()} @{ $_[0]->_req_params() }),
        since => $self->since->ymd(), until => $self->until->ymd,
        user_agent => $self->_request->user_agent_id,
    };
}

# request params
has workspace_id => (is => 'ro', required => 1,);
has since        => (is => 'ro', lazy => 1, builder => 1,);
has until        => (is => 'ro', lazy => 1, builder => 1,);
sub _build_since { shift->until->clone->subtract(days => 6) }
sub _build_until { DateTime->now }


# response params
has $_ => (is => 'ro', lazy => 1, builder => quote_sub(qq| \$_[0]->raw->{$_} |))
    for (qw(total_grand total_billable total_currencies data));



1;
__END__

=encoding utf-8

=head1 NAME

WebService::Toggl::Report - Base Role for WebService::Toggl::Report objects

=head1 DESCRIPTION

This role provide behavoir common to all C<WebService::Toggl::Report::>
objects.

=head1 REQUIRES

=head2 api_path

Consuming classes must provide their endpoint on the Reports API.
Ex. The L<WebService::Toggl::Report::Summary> object's C<api_path> is
C<summary>.

=head1 ATTRIBUTES

=head2 base_url

The base of the URL for the Toggl Reports API.  Defaults to C</reports/api/v8>.

=head2 my_url

URL for the current Report object.

=head2 raw

The raw data structure returned by querying the API.

=head2 workspace_id

The ID of the workspace for which the report is being generated.

=head2 since / until

L<DateTime> objects representing the bounding period for the report.
Defaults to C<until> = today, C<since> = today - 6 days

=head1 RESPONSE PARAMETERS

=head2 total_grand / total_billable / total_currencies / data

See the L<Toggl API Docs|https://github.com/toggl/toggl_api_docs/blob/master/reports.md#successful-response>.

=head1 LICENSE

Copyright (C) Fitz Elliott.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Fitz Elliott E<lt>felliott@fiskur.orgE<gt>

=cut
