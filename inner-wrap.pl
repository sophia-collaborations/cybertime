use strict;
use argola;
use wraprg;
use chobdate;

my $diryes = 0;
my $dirat;
my $curpid;
my $qrycmdn;

my $data_file;
my $gt_last_at;
my $gt_last_for;

my $idle_source;
my $max_elaps = 40;
my $max_idle; # Set this shortly after:



$max_idle = int((60 * 3) + 0.2);
#$max_idle = 50;


sub opto__dir__do {
  $dirat = &argola::getrg();
  $diryes = 10;
}; &argola::setopt('-dir',\&opto__dir__do);

&argola::runopts();


$idle_source = 'echo $((`ioreg -c IOHIDSystem | sed -e ' . "'" . '/HIDIdleTime/ !{ d' . "'" . ' -e ' . "'" . 't' . "'" . ' -e ' . "'" . '}' . "'" . ' -e ' . "'" . 's/.* = //g' . "'" . ' -e ' . "'" . 'q' . "'" . '` / 1000000000))';


if ( $diryes < 5 )
{
  die '
FATAL ERROR: No directory specified.
Please use "-dir" option to rectify this.

';
}


sleep(2);
$curpid = $$;
system("echo","Process: " . $curpid);
$qrycmdn = "echo";
&wraprg::lst($qrycmdn,$curpid);
$qrycmdn .= ' >';
&wraprg::lst($qrycmdn,($dirat . "/valid-pid.txt"));
system($qrycmdn);
$qrycmdn = 'cat';
&wraprg::lst($qrycmdn,($dirat . "/valid-pid.txt"));
sub ifstayo {
  my $lc_a;
  $lc_a = `$qrycmdn`; chomp($lc_a);
  if ( $lc_a ne $curpid ) { exit(0); }
}
sleep(5);
&ifstayo();




$data_file = ($dirat . "/count-file.txt");
{
  my $lc_cm;
  my $lc_cont;
  my @lc_sgs;
  $lc_cm = "cat";
  &wraprg::lst($lc_cm,$data_file);
  $lc_cont = `$lc_cm`; chomp($lc_cont);
  @lc_sgs = split(quotemeta(':'),$lc_cont);
  $gt_last_at = $lc_sgs[1];
  $gt_last_for = $lc_sgs[2];
}


sub savaeo {
  my $lc_dsf;
  my $lc_cm;
  $lc_dsf = ($dirat . '/day-' . $_[0] . '.txt');
  $lc_cm = "echo";
  &wraprg::lst($lc_cm,$_[1]);
  $lc_cm .= ' >';
  &wraprg::lst($lc_cm,$lc_dsf);
  system($lc_cm);
}



system("echo","Starting Cycle:");
while ( 2 > 1 ) { &zangry(); }
sub zangry {
  my $lc_cm;
  my $lc_dt;
  my $lc_now;
  my $lc_elaps;
  my $lc_ol_date;
  my $lc_new_date;
  my $lc_idln;
  
  sleep(5);
  
  &ifstayo();
  $lc_cm = "echo";
  $lc_dt = `date`; chomp($lc_dt);
  &wraprg::lst($lc_cm,"Starting Round:",$lc_dt);
  system($lc_cm);
  
  # Find the Newest Time:
  $lc_now = &chobdate::nowo();
  if ( $lc_now < $gt_last_at )
  {
    if ( $lc_now < ( $gt_last_at - ( 60 * 60 ) ) ) { $gt_last_at = $lc_now; }
    return;
  }
  
  # Find dates: Old and New:
  $lc_ol_date = &chobdate::atto($gt_last_at);
  $lc_new_date = &chobdate::atto($lc_now);
  system("echo","Previous: " . $lc_ol_date);
  system("echo"," Current: " . $lc_new_date);
  
  # Find elapsation:
  $lc_elaps = int(($lc_now - $gt_last_at) + 0.2);
  if ( $lc_elaps > $max_elaps ) { $lc_elaps = $max_elaps; }
  if ( $lc_elaps < 0 ) { return; }
  
  # Clear things --- if it's a new day:
  if ( $lc_ol_date ne $lc_new_date )
  {
    if ( $gt_last_at ne '' )
    {
      &savaeo($lc_ol_date,$gt_last_for);
      $gt_last_for = 0;
    }
  }
  
  # Find idle time:
  $lc_idln = `$idle_source`; chomp($lc_idln);
  system("echo","System Idle for " . $lc_idln . " seconds:");
  
  # Let the New Become the Old
  $gt_last_at = $lc_now;
  if ( $lc_idln < $max_idle )
  {
    $gt_last_for = int($gt_last_for + $lc_elaps + 0.2);
  }
  system("echo","Total So Far: " . $gt_last_for);
  
  
  
  # Now we save stuff to the count file:
  $lc_cm = "echo";
  &wraprg::lst($lc_cm,('x:' . $gt_last_at . ':' . $gt_last_for . ':x'));
  $lc_cm .= ' >';
  &wraprg::lst($lc_cm,$data_file);
  system($lc_cm);
  
  # And we save today's dish:
  &savaeo($lc_ol_date,$gt_last_for);
  
  
  system("echo \"Ending Round:\"");
}






