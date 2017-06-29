#!/usr/bin/perl
use XML::DOM;


# 输入判断
my $file = shift;
chomp(my $hostname=qx/hostname/);
$file="${hostname}.xml" if (!$file);


#　xml 分析
sub ipt_xml()
{
my $flag = ();
my $parser = new XML::DOM::Parser;
my $doc = $parser->parsefile ("$file");
my $nodes = $doc->getElementsByTagName ("docker");
my $n = $nodes->getLength;
my %ipt_hash;


for (my $i = 0; $i < $n; $i++)
 {
     my $node = $nodes->item ($i);                                                     
     my $portmap = $node->getAttributeNode ("gameportmapping"); 
     my $hostname = $node->getAttribute ("hostname");
     my $wlj_nei = $node->getAttribute ("serverip");                                  
     $all=$portmap ->getValue;                                                        
     
     my @all_rule = split(/,/, $all);
     $ipt_hash{$hostname} = [@all_rule];
     #print "(@{$ipt_hash{$hostname}})\n";    
     for ((@{$ipt_hash{$hostname}})) {print "$hostname:$_\n";}
 }
}
 
ipt_xml();



 # Print doc file
 #$doc->printToFile ("out.xml");

 # Print to string
 #print $doc->toString;

 # Avoid memory leaks - cleanup circular references for garbage collection
 #$doc->dispose;





=cut

<?xml version="1.0" encoding="utf-8"?>
<Datas>
<docker  hostname="kofgame110_ios" physicalHostname="docker-ct7-31-szq" sertagid="GR62962" ip="115.182.58.105" serverip="10.10.4.244" cpu="12" created_time="2016-12-28 10:44:28" name="IOS-110服-死亡舞步" serverid="3110" localid="3110" gameid="3" auany="115.182.58.96:29200" logstoreprivateip="10.10.0.10" logstorepublicip="115.182.58.45" unique="1" cloudandservice="suzhoujie" gameportmapping="28993-53992,28994-53993,28995-53994,28996-53995,28997-53996,28998-53997,28999-53998,29000-53999" serviceportmapping="" />
<docker  hostname="kofgame416_and" physicalHostname="docker-ct7-31-szq" sertagid="GR62962" ip="115.182.58.105" serverip="10.10.4.245" cpu="12" created_time="2016-10-08 15:34:39" name="安卓-416服-心魔之殇" serverid="2416" localid="2416" gameid="3" auany="10.10.0.51:29200" logstoreprivateip="10.10.0.10" logstorepublicip="115.182.58.45" unique="1" cloudandservice="suzhoujie" gameportmapping="28993-54992,28994-54993,28995-54994,28996-54995,28997-54996,28998-54997,28999-54998,29000-54999" serviceportmapping="" />
<docker  hostname="kofgame109_ios" physicalHostname="docker-ct7-31-szq" sertagid="GR62962" ip="115.182.58.105" serverip="10.10.4.241" cpu="12" created_time="2016-12-28 10:44:10" name="IOS-109服-噬心之仇" serverid="3109" localid="3109" gameid="3" auany="115.182.58.96:29200" logstoreprivateip="10.10.0.10" logstorepublicip="115.182.58.45" unique="1" cloudandservice="suzhoujie" gameportmapping="28993-50992,28994-50993,28995-50994,28996-50995,28997-50996,28998-50997,28999-50998,29000-50999" serviceportmapping="" />
<docker  hostname="kofgame88_ios" physicalHostname="docker-ct7-31-szq" sertagid="GR62962" ip="115.182.58.105" serverip="10.10.4.242" cpu="12" created_time="2016-10-20 17:19:03" name="IOS-88服-百战成钢" serverid="3088" localid="3088" gameid="3" auany="115.182.58.96:29200" logstoreprivateip="10.10.0.10" logstorepublicip="115.182.58.45" unique="1" cloudandservice="suzhoujie" gameportmapping="28993-51992,28994-51993,28995-51994,28996-51995,28997-51996,28998-51997,28999-51998,29000-51999" serviceportmapping="" />
<docker  hostname="kofgame558_and" physicalHostname="docker-ct7-31-szq" sertagid="GR62962" ip="115.182.58.105" serverip="10.10.4.243" cpu="12" created_time="2017-02-24 09:59:59" name="安卓-558服-星光璀璨" serverid="2558" localid="2558" gameid="3" auany="10.10.0.51:29200" logstoreprivateip="10.10.0.10" logstorepublicip="115.182.58.45" unique="1" cloudandservice="suzhoujie" gameportmapping="28993-52992,28994-52993,28995-52994,28996-52995,28997-52996,28998-52997,28999-52998,29000-52999" serviceportmapping="" />
<docker  hostname="kofgame61_ios" physicalHostname="docker-ct7-31-szq" sertagid="GR62962" ip="115.182.58.105" serverip="10.10.4.247" cpu="12" created_time="2016-08-18 15:49:23" name="IOS-61服-拳风传奇" serverid="3061" localid="3061" gameid="3" auany="115.182.58.96:29200" logstoreprivateip="10.10.0.10" logstorepublicip="115.182.58.45" unique="1" cloudandservice="suzhoujie" gameportmapping="28993-56992,28994-56993,28995-56994,28996-56995,28997-56996,28998-56997,28999-56998,29000-56999" serviceportmapping="" />
<docker  hostname="kofgame280_and" physicalHostname="docker-ct7-31-szq" sertagid="GR62962" ip="115.182.58.105" serverip="10.10.4.246" cpu="12" created_time="2016-07-04 13:03:19" name="安卓-280服-风吹火起" serverid="2280" localid="2280" gameid="3" auany="115.182.58.7:29200" logstoreprivateip="10.10.0.10" logstorepublicip="115.182.58.45" unique="1" cloudandservice="suzhoujie" gameportmapping="28993-55992,28994-55993,28995-55994,28996-55995,28997-55996,28998-55997,28999-55998,29000-55999" serviceportmapping="" />
<docker  hostname="kofgame559_and" physicalHostname="docker-ct7-31-szq" sertagid="GR62962" ip="115.182.58.105" serverip="10.10.4.248" cpu="12" created_time="2017-02-24 10:00:08" name="安卓-559服-无敌之龙" serverid="2559" localid="2559" gameid="3" auany="10.10.0.51:29200" logstoreprivateip="10.10.0.10" logstorepublicip="115.182.58.45" unique="1" cloudandservice="suzhoujie" gameportmapping="28993-57992,28994-57993,28995-57994,28996-57995,28997-57996,28998-57997,28999-57998,29000-57999" serviceportmapping="" />
</Datas>

=cut
