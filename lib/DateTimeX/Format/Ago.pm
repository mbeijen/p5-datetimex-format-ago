package DateTimeX::Format::Ago;

use 5.010;
use common::sense;
use utf8;

BEGIN {
	$DateTimeX::Format::Ago::AUTHORITY = 'cpan:TOBYINK';
	$DateTimeX::Format::Ago::VERSION   = '0.002';
}

use Carp 0 qw[];
use DateTime 0 ;
use Scalar::Util 0 qw[blessed];

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
	$__{FR} = {
		future    => "à l'avenir",
		recent    => "récemment",
		years     => ["il y a %d ans", "il y a un an"],
		months    => ["il y a %d mois", "il y a un mois"],
		weeks     => ["il y a %d semaines", "il y a une semaine"],
		days      => ["il y a %d jours", "il y a un jour"],
		hours     => ["il y a %d heures", "il y a une heure"],
		minutes   => ["il y a %d minutes", "il y a une minute"],
		};
	
	# These courtesy of Google Translate...
	$__{ES} = {
		future    => "en el futuro",
		recent    => "ahora mismo",
		years     => ["hace %d años", "hace un año"],
		months    => ["hace %d meses", "hace un mes"],
		weeks     => ["hace %d semanas", "hace una semana"],
		days      => ["hace %d días", "hace un día"],
		hours     => ["hace %d horas", "hace una hora"],
		minutes   => ["hace %d minutos", "hace un minuto"],
		};
	$__{PT} = {
		future    => "no futuro",
		recent    => "só agora",
		years     => ["%d anos atrás", "há um ano"],
		months    => ["%d meses atrás", "há um mês"],
		weeks     => ["%d semanas atrás", "há uma semana"],
		days      => ["%d days atrás", "há um dia"],
		hours     => ["%d horas atrás", "há uma hora"],
		minutes   => ["%d minutos atrás", "há um minuto"],
		};

	# ISO 639-2
	$__{ENG} = $__{EN};
	$__{FRE} = $__{FR};
	$__{FRA} = $__{FR};
	$__{ENG} = $__{EN};
	$__{GER} = $__{DE};
	$__{DEU} = $__{DE};
	$__{SPA} = $__{ES};
	$__{POR} = $__{PT};
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

sub _now
{
	if ($INC{'Time/HiRes.pm'})
	{
		return DateTime->from_epoch(epoch => Time::HiRes::time());
	}
	return DateTime->now;
}

sub format_datetime
{
	my ($self, $datetime) = @_;
	$self = $self->new unless blessed($self);
	
	my $now     = $self->_now;
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
	
	Carp::croak(sprintf("%s doesn't know about language '%s'", __PACKAGE__, $self->{language}));
}

__PACKAGE__
__END__

=head1 NAME

DateTimeX::Format::Ago - I should have written this module "3 years ago"

=head1 SYNOPSIS

  my $then = DateTime->now->subtract(days => 3);
  say DateTimeX::Format::Ago->format_datetime($then); # "3 days ago"

=head1 DESCRIPTION

Ever wished DateTime::Format::Natural had a C<format_datetime>
method? This module provides human-friendly datetime formatting,
outputting strings like "3 days ago".

Primary use case: websites that show a list of a person's recent
activities.

=head2 Constructor

=over

=item C<< new(language => $lang) >>

Creates a formatter object for the given language (a BCP47 language code).
If the language is omitted, extracts it from C<< $ENV{LANG} >>.

Decent English ('en'), German ('de') and French ('fr') support is provided.
Portuguese ('pt') and Castillian Spanish ('es') are also provided, but some
of the strings were translated with Google Translate, so they might not be
perfect.

=back

=head2 Methods

=over

=item C<< format_datetime($dt) >>

Returns something like "3 days ago", "just now" or "hace un año".

=item C<< parse_datetime($string) >>

Croaks. Don't use this.

=back

=head1 BUGS AND LIMITATIONS

=head2 High resolution datetimes

Imagine the time is currently 2020-01-01T12:00:00.200. If you try to format
the time 2020-01-01T12:00:00.100 you'll get back the result "in the future".
So what's going on? DateTimeX::Format::Ago figures out when "now" is using
C<< DateTime->now >>, which rounds back to the nearest whole second.

If you know you're going to be dealing with high resolution datetimes, and
don't want to occasionally see "in the future" for times in the very recent
past, then use L<Time::HiRes>.

 use Time::HiRes qw();

That's all you need to do. Merely loading it will give DateTimeX::Format::Ago
an indication that you want it to use a more accurate idea of "now".

=head2 Translations

This module only supports a handful of languages. I'm seeking translations.
Feel free to attach patches for other languages as bug reports.

=head2 Reporting Bugs

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=DateTimeX-Format-Ago>.

=head1 SEE ALSO

L<DateTime>, L<DateTime::Format::Natural>.

L<http://www.rfc-editor.org/rfc/bcp/bcp47.txt>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2011-2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

