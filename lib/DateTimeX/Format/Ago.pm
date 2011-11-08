package DateTimeX::Format::Ago;

use 5.010;
use common::sense;
use constant { FALSE => 0, TRUE => 1 };
use utf8;

BEGIN {
	$DateTimeX::Format::Ago::AUTHORITY = 'cpan:TOBYINK';
	$DateTimeX::Format::Ago::VERSION   = '0.001';
}

use Carp 0 qw[];
use DateTime 0 ;
use Scalar::Util 0 qw[blessed refaddr];

our %__;
BEGIN {
	$__{EN} = {
		future    => "in the future",
		recent    => "just now",
		years     => ["%d years ago", "a year ago"],
		months    => ["%d months ago", "a month ago"],
		weeks     => ["%d weeks ago", "a week ago"],
		days      => ["%d days ago", "a day ago"],
		hours     => ["%d hours ago", "an hour ago"],
		minutes   => ["%d minutes ago", "a minute ago"],
		};
	$__{DE} = {
		future    => "in der Zukunft",
		recent    => "gerade jetzt",
		years     => ["vor %d Jahren", "vor einem Jahr"],
		months    => ["vor %d Monaten", "vor einem Monat"],
		weeks     => ["vor %d Wochen", "vor einer Woche"],
		days      => ["vor %d Tagen", "vor einem Tag"],
		hours     => ["vor %d Stunden", "vor einer Stunde"],
		minutes   => ["vor %d Minuten", "vor einer Minute"],
		};
}

sub new
{
	my ($class, %options) = @_;
	$options{'language'} //= ($ENV{LANG} // 'en');
	$options{'language'} =~ s/\..*$//;
	bless \%options, $class;
}

sub parse_datetime
{
	Carp::croak(sprintf("%s doesn't do parsing", __PACKAGE__));
}

sub format_datetime
{
	my ($self, $datetime) = @_;
	$self = $self->new unless blessed($self);
	
	my $now     = DateTime->now;
	my $delta   = $now - $datetime;
	my %strings = $self->_strings;
	
	return $strings{future} if $delta->is_negative;
	
	foreach my $unit (qw/years months weeks days hours minutes/)
	{
		$strings{$unit}[0] = uc "%d $unit ago"
			unless defined $strings{$unit}[0];
		
		my $n = $delta->in_units($unit);
		
		if ($n > 0)
		{
			if (exists $strings{$unit}[$n]
			and defined $strings{$unit}[$n])
			{
				return sprintf($strings{$unit}[$n], $n);
			}
			
			return sprintf($strings{$unit}[0], $n);
		}
	}
	
	return $strings{recent};
}

sub _strings
{
	my ($self) = @_;
	$self = $self->new unless blessed($self);
	
	my $language = uc $self->{language};
	while (length $language)
	{
		return %{$__{$language}} if defined $__{$language};
		$language =~ s/(^|[_-])([^_-]*)$//;
	}
	
	Carp::croak(sprintf("%s doesn't know about language %s", __PACKAGE__, $self->{language}));
}

TRUE;

__END__

=head1 NAME

DateTimeX::Format::Ago - I should have written this module "3 years ago"

=head1 SYNOPSIS

  my $then = DateTime->now->subtract(days => 3);
  say DateTimeX::Format::Ago->format_datetime($then); # "3 days ago"

=head1 DESCRIPTION

Ever wished DateTime::Format::Natural had a C<format_datetime>
method?

=head2 Constructor

=over

=item C<< new(language => $lang) >>

Creates a formatter object. If the language is ommitted, extracts it from
C<< $ENV{LANG} >>.

=back

=head2 Methods

=over

=item C<< format_datetime($dt) >>

Returns something like "3 days ago" or "just now".

=item C<< parse_datetime($string) >>

Croaks. Don't use this.

=back

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=DateTimeX-Format-Ago>.

I'm actively seeking translations - only have English and German so far.
Feel free to attach patches for other languages as bug reports.

=head1 SEE ALSO

L<DateTime>, L<DateTime::Format::Natural>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2011 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

