#!/bin/php
<?php
$cl65_map_file = $argv[1];

Class Segment{
	
	public $name;
	public $start;
	public $end;
	public $size;	
	
	function Segment($name, $start, $end, $size){
		$this->name = $name;
		$this->start = $start;
		$this->end = $end;
		$this->size = $end;
	}
	
	function __toString(){
		return "Segment: ".$this->name."\t".$this->start."\t".$this->end."\t".$this->size."\n";	
	}
}

Class C64Map{
	public $map_png = "iVBORw0KGgoAAAANSUhEUgAAAEAAAAEABAMAAADxaG01AAAAA3NCSVQICAjb4U/gAAAAJ1BMVEX/
///////////////////////////////////////////z8/MAAACp4EnCAAAADXRSTlMAM0RVZne7
zN3u////PZy1HgAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmly
ZXdvcmtzIENTNAay06AAAAAWdEVYdENyZWF0aW9uIFRpbWUAMDYvMDkvMTAZHqyRAAACKUlEQVRo
ge2YvU7DMBCA3fLTpmLgEbpRMfEavA2CjYmfDTFUbFgMSEWUnPwETN2glh+KOE6oE/vuShG0VXLR
DUm/2r7L5XxnYRgRM0HKgZglAGNfA0Aak/oaAEpXrwhgtK8hYLL/ebrKFAzAWsH6IerARgNdCQCh
Jxc3PRuD4btY3Aw4oM8B3TsAEshnaQrQuTyngcR80EB1lu0D9qSNB8CBpEiNKDDggF4BoJ7sZDFp
5ZqwIpAWaB4gUyFhoQGQKJ0oox8LHQeAtN8CfF/PdUAqC6jsJ6d1wO63+t3o7Eenql4/2AdATgFK
SwoQgrOC9QPvyRbYQmDH5ckLFChytT7BgDJXnzEjVKIyqB8AFA442XTglLFi98n5YYwBCefJwtVz
4l1ou4hbQQB1kzYSsFakQxxYzlH4u+CD1pUPb+gaYtICTQP+pXNXZOee7fcG/M49OH9oO/cW+Cug
qB+m6JbUL8JwggFlKkZbuXKEOQa4+oHoN8uJ1g8cU8AotwI1U4j73A+vOOBah5dfjMCugbXCynpd
zcZDGVHs+QMbkw/MGqZD2oqqtEDTgH+pH2RK1g9KA1c/2BHa+qEF1gB05Q0N9CtZOgIs15COKq1e
BLg3VzRQO9prKGBzyYQAgn01CmgO+ESBfXcMg68hF8qKjQGokMvlaHpIAzVpDiABUl8DICuVta8h
oCH1NQKkwtfIFFr4usII9nvz9OeATPOj/W8NgPqjOmAY+QKxxlzYMhIOFgAAAABJRU5ErkJggg==";
	public $col_c64 = Array(/*0x000000,0xFFFFFF,*/0x983039,0x57BCB3,0xA043AD,0x33953D,0x2E2DBD,0xCBCE40,0x9F540F,0x633700,0xCB636B,0x444545,0x747473,0x7DDE86,0x6D6AF3,0xA5A6A5);
	public $col_key = Array(/*"BLACK","WHITE",*/"RED","CYAN","PURPLE","DGREEN","DBLUE","YELLOW","ORANGE","BROWN","LRED","DGREY","GREY","LGREEN","LBLUE","LGREY");
	public $segs;
	public $src;
	
	function C64Map($cl65_map_file){
		$this->segs = Array();
		$this->src = $cl65_map_file;
		echo "Interpreting CL65 memory map...\n";
		$memmap = explode("\n",file_get_contents($cl65_map_file));
		$found_segs = false;
		$seek_segs = true;
		for($i=0; $i<count($memmap); $i++){
			$ln = $memmap[$i];
			if(!$found_segs){
				if(substr($ln,0,13)=="Segment list:"){
					$found_segs = true;
					echo "Found Segments:\n";
					$i+=3;
					continue;
				}
			} else if($seek_segs){
				if(strlen($ln)<2){
					// end of segs
					$seek_segs = false;
				} else {
					preg_match("/^([^\s]*)[\s]*([^\s]*)[\s]*([^\s]*)[\s]*([^\s]*)/", $ln, $match);
					if(count($match)==5){
						$seg = new Segment($match[1], "0x".ltrim($match[2],"0"), "0x".ltrim($match[3],0), "0x".ltrim($match[4],0));
						$this->addSegment($seg);
						echo $seg;
					}
				}
			} else break;
		}
	}
	
	function convert(){
		echo "Converting...\n";
		
		$gd_img = imagecreatefromstring(base64_decode($this->map_png));
		$sx = imagesx($gd_img);
		$sy = imagesy($gd_img);
		imagesavealpha($gd_img, true);
		
		$gd_overlay = imagecreatetruecolor($sx,$sy);
		imagesavealpha($gd_overlay, true);
		$white = imagecolorallocatealpha($gd_overlay, 255, 255, 255, 100);
		imagefill($gd_overlay, 0, 0, $white);
		
		$pixelcount =  $sx * $sy;
		$col_i = 0;
		echo count($this->segs)." segments\n";
		$key_str = "MEMORY USAGE KEY:\n-------------\n";
		
		for($i=0; $i<count($this->segs); $i++){
			$col_i = $i % count($this->col_c64);
			$seg = $this->segs[$i];
			$start_px = hexdec($seg->start)/(65536/$pixelcount);
			$end_px = hexdec($seg->end)/(65536/$pixelcount);
			$lx = intval($start_px % $sx);
			$ly = intval(($start_px - $lx)/$sx);
			$fx = intval($end_px % $sx);
			$fy = intval(($end_px - $fx)/$sx);
			echo $seg->name." : $lx, $ly to $fx, $fy\n";
			$cols = hex2rgb($this->col_c64[$col_i]);
			$key_str.=$seg->name.str_repeat(" ",15-strlen($seg->name)).":\t".$this->col_key[$col_i]."\n";
			
			// 50% transparent colours should show any dodgy overlaps!
			$col_id = imagecolorallocatealpha($gd_overlay, $cols['r'], $cols['g'], $cols['b'], 30);
			// first and last line if more than one line
			if($ly!=$fy){
				imageline($gd_overlay, $lx, 1+$ly, $sx, 1+$ly, $col_id);
				imageline($gd_overlay, 0, 1+$fy, $fx, 1+$fy, $col_id);
				// box if more than 2 pix high
				if($fy-$ly > 2){
					imagefilledrectangle($gd_overlay, 0, 1+$ly+1, $sx, 1+$fy-1, $col_id);
				}
			} else {
				// all on 1 line!
				imageline($gd_overlay, $lx, 1+$ly, $fx, 1+$fy, $col_id);
			}
		}
		$key_str .= "-------------\n";
		imagecopymerge($gd_overlay, $gd_img, 0, 0, 0, 0, $sx, $sy, 100);
		$filename = "build/map.png";
		imagepng($gd_overlay, $filename);
		$fp = fopen("build/mapkey.txt","w");
		fputs($fp, $key_str);
		fclose($fp);
	}
	
	function addSegment($seg){
		$this->segs[] = $seg;
	}
}

function hex2rgb($hex){
	$hex = dechex($hex);
	$rgb = array();
	$rgb['r'] = hexdec(substr($hex, 0, 2));
	$rgb['g'] = hexdec(substr($hex, 2, 2));
	$rgb['b'] = hexdec(substr($hex, 4, 2));
	return $rgb;
}

$map = new C64Map($cl65_map_file);
$map->convert();

?>