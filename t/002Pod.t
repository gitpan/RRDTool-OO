
use Test::More qw(no_plan);
use RRDTool::OO;
use strict;
use warnings;

my $count = 0;

#    use Log::Log4perl qw(:easy);
#
#    Log::Log4perl->easy_init({
#        level    => $INFO, 
#        category => 'rrdtool',
#        layout   => '%m%n',
#    }); 

### START POD HERE ###

        # Constructor     
    my $rrd = RRDTool::OO->new(
                 file => "myrrdfile.rrd" );

        # Create a round-robin database
    $rrd->create(
         step        => 1,  # one-second intervals
         data_source => { name      => "mydatasource",
                          type      => "GAUGE" },
         archive     => { rows      => 5 });

    ok(1, "Create");

        # Update RRD with sample values, use current time.
    for(1..5) {
        $rrd->update($_);
        ok(1, "Update");
        sleep(1);
    }

        # Start fetching values from one day back, 
        # but skip undefined ones first
    $rrd->fetch_start();
    $rrd->fetch_skip_undef();

        # Fetch stored values
    while(my($time, $value) = $rrd->fetch_next()) {
         $count++;
         #print "$time: ", 
         #      defined $value ? $value : "[undef]", "\n";
    }

        # Draw a graph in a PNG image
    $rrd->graph(
      file           => "mygraph.png",
      vertical_label => 'My Salary',
      start          => time() - 10,
    );

### END POD HERE ###

ok($count > 2, "Fetch");

END { unlink "mygraph.png";
      unlink "myrrdfile.rrd";
    }
