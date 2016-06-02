use strict;
use warnings;
use DateTimeX::Format::Ago;
use Test::More tests => 200;

# Some of these tests rely on computation being carried out reasonably fast.
# I can only see them failing on really slow and overloaded CPUs though.

my $ago = DateTimeX::Format::Ago->new(language => 'NL');

foreach my $unit (qw/years months weeks days hours minutes/)
{
	my $max = {
		years   => 25,
		months  => 11,
		weeks   => 3,  # don't want to fail tests in February 2013.
		days    => 6,
		hours   => 22, # don't want to fail due to daylight savings.
		minutes => 59,
	}->{$unit};

	my $when = DateTime->now->subtract($unit => 1);
	is($ago->format_datetime($when), {
		'years'    => 'een jaar geleden',
		'months'   => 'een maand geleden',
		'weeks'    => 'een week geleden',
		'days'     => 'een dag geleden',
		'hours'    => 'een uur geleden',
		'minutes'  => 'een minuut geleden',
	}->{$unit});

	my $nlunit = {
		years    => 'jaar',
		months   => 'maanden',
		weeks    => 'weken',
		days     => 'dagen',
		hours    => 'uur',
		minutes  => 'minuten',
	}->{$unit};

	for my $n (2..$max)
	{
		my $when = DateTime->now->subtract($unit => $n);
		is($ago->format_datetime($when), "$n $nlunit geleden");
	}
}

for my $n (1..58)
{
	my $when = DateTime->now->subtract(seconds => $n);
	is($ago->format_datetime($when), "nu");
}

for my $n (62..70)
{
	my $when = DateTime->now->subtract(seconds => $n);
	is($ago->format_datetime($when), "een minuut geleden");
}

for my $unit (qw/seconds minutes hours days weeks months years/)
{
	my $when = DateTime->now->add($unit => 3);
	is($ago->format_datetime($when), "in de toekomst");
}
