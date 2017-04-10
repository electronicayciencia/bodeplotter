#!/bin/bash

# Call a remote raspberry frequency plotter and retrieve data.

REMOTEHOST=root@192.168.1.121
REMOTECMD=/home/pi/bodeplotter/raspi/freqplot

if [ "$#" -ne 5 ]
then
	echo "Usage $0 output_file plot_head npoints start_freq stop_freq"
	exit 1
fi

outfile=$1
head=$2
npoints=$3
fstart=$4
fstop=$5


result=`ssh $REMOTEHOST $REMOTECMD $npoints $fstart $fstop`

echo "
set style line 1 lc rgb '#d95319' lt 1 lw 3
set style line 12 lc rgb '#808080' lt 1 lw 0.3
set style line 13 lc rgb '#E0E000' lt 1 lw 6

set grid xtics mxtics ytics
set grid xtics ytics mxtics mytics ls 12, ls 12

set border 3
set yrange [0:100]
set xrange [$fstart:$fstop]
set mxtics 10
set xtics 10 
set ytics nomirror
set xtics nomirror
set autoscale xfix
set logscale x

set xlabel 'Frecuencia (Hz)'
set ylabel 'Lectura ADC (%)'

set obj 21 rect from graph 0, graph 0 to graph 1, graph 1 lw 0 fs solid 0.99 fc rgb '#D6E8D9' behind

#set arrow 20 from 125000,0 to 125000,100 nohead ls 13

#set obj 21 rect from screen 0,0 to screen 1,1 fillcolor rgb '#EAEAEA' behind
#set obj 20 rect from graph 0, graph 0 to graph 1, graph 1 lw 0 fs solid 0.99 fc rgb '#DFEAE6' behind

#plot [10:100000] x

set term pngcairo size 1500, 700 truecolor nocrop noenhanced font 'Arial,16'
set title 'Respuesta en frecuencia para \"$head\"'
set output '$outfile'
plot '-' using 1:(\$2/255*100) sm un ls 1 t ''
$result
" | gnuplot

ps -ef | grep -qs "[f]eh" || feh --reload 1 $outfile &

