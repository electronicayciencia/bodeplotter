#!/usr/bin/perl

# Graficador de frecuencias usando raspberry gpio clk
# Reinoso G.       15/01/2017

use strict;
use warnings;
use Time::HiRes qw/sleep/;

$| = 1;

my $FMIN = $ARGV[0];
my $FMAX = $ARGV[1];

my $ADCCHAN = 2;
my $ADCADDR = 0x48;

`gpio mode 7 clock`;

while(1) {

	my $frec = loginv_rnd($FMIN, $FMAX);
	
	`gpio clock 7 $frec`;

	`i2cset -y 1 $ADCADDR $ADCCHAN`;
	sleep 0.1;  # estabilizar la tensión en C
	`i2cget -y 1 $ADCADDR`;

	sleep 0.3;  # lectura del ADC
	my $v = `i2cget -y 1 $ADCADDR`;
	chomp $v;

	$v = hex $v;

	if ($v >= 140 and $v <= 146) {
		`i2cset -y 1 $ADCADDR $ADCCHAN`;
		sleep 0.1;
		$v = `i2cget -y 1 $ADCADDR`;
		sleep 1.0;
		$v = `i2cget -y 1 $ADCADDR`;
		chomp $v;
		$v = hex $v;
	}

	printf("%d\t%d\n", $frec, $v);
}

# calcula un número aleatorio entre un máximo y un mínimo
# con distribución logatirmica inversa
# de forma que al representarse en un gráfico semilogarítmico
# se muestra como una distribución uniforme
# Uso: loginv_rnd (min, max)
sub loginv_rnd {
	my ($fmin, $fmax) = @_;

	my $lfmin = log($fmin);
	my $lfmax = log($fmax);

	my $lfrnd = rand()*($lfmax-$lfmin) + $lfmin;
	my $frnd = int(exp($lfrnd));

	return $frnd;
}
