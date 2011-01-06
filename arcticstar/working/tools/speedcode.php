<?php
// make speed code for arcticstar
$gfx_start = 0x9000;
$gfx_width = 160;
$gfx_height = 620;
$gfx_size = ($gfx_width/8)*$gfx_height;
$perpsective_strength = 15;
$row_width = $gfx_width / 8;
$field_depth = 96;
$chrset1 = 0x4000;
$chrset2 = 0x4800;
$starting_chr = 96;
// src addresses for each row
Class LandscapeBitmap{
	public $start = 0;
	public $end = 0;
	public $width = 0;
	public $height = 0;
	public $depth = 0;
	public $perpsective_strength = 0;
	public $starting_chr = 0;
	public $chrset1;
	public $chrset2;
	public $srcLocations = Array(); // one for each row start
	public $destLocations = Array(); // start for each row in chrsets
	function LandscapeBitmap($start, $width, $height, $field_depth, $perpsective_strength, $starting_chr, $chrset1, $chrset2){
		$this->start = $start;
		$this->width = $width;
		$this->height = $height;
		$this->depth = $field_depth;
		$this->chrset1 = $chrset1;
		$this->chrset2 = $chrset2;
		$this->perpsective_strength = $perpsective_strength;
		$this->starting_chr = $starting_chr;
		$this->end = $this->start + $this->getSize();
	}
	function getSize(){
		return ($this->width/8)*$this->height;	
	}
	function srcLocations(){
		$counter = $this->start;
		$loc = Array();
		$loc[]=$counter;
		for($a = 0; $a<$this->depth-1; $a++){
			$foo = ($this->perpsective_strength)*sin(($a*M_PI/2)/$this->depth);
			$frac = floor(10*($foo - round($foo)));
			if($frac < 5 && $frac%2 == 1){
				$foo--;	
			}
			$step = $this->perpsective_strength-floor($foo);
			$counter+=$step*$this->width/8;
			if($counter > $this->end) $counter -= $this->getSize();
			$loc[]=$counter;
		}
		$this->srcLocations = $loc;
	}
	function destLocations(){
		$loc = Array();
		//required locations
		$spaces = ($this->width / 8) * ($this->depth / 8);
		$spaces_per_chrset = $spaces / 2;
		$row_to_skip = 3;
		$rows_per_chrset = ($this->depth / 16);
		$start1 = $this->chrset1+$row_to_skip*32*8;
		for($i = 0; $i < $rows_per_chrset; $i++){
			for($a=0; $a<8; $a++){
				$loc[]=$start1 + $a + $i*($this->width);
			}
		}
		$start2 = $this->chrset2+$row_to_skip*32*8;
		for($i = 0; $i < $rows_per_chrset; $i++){
			for($a=0; $a<8; $a++){
				$loc[]=$start2 + $a + $i*($this->width);
			}
		}
		$this->destLocations = $loc;
	}
	function printSrcTables(){
		$out = "";
		$hi_out = "src_row_HI:\t.byte\t";
		$lo_out = "src_row_LO:\t.byte\t";
		$hi = "";
		$lo = "";
		foreach($this->srcLocations as $loc){
			$hex = dechex($loc);
			$hi.="$".substr($hex,0,2);
			$lo.="$".substr($hex,2,2);
			$hi.=",";
			$lo.=",";
		}
		$hi_out .= substr($hi, 0, strlen($hi)-1);
		$lo_out .= substr($lo, 0, strlen($lo)-1);
		$out .= $hi_out."\n".$lo_out."\n";;
		return $out;
	}
	
	function printDestTables(){
		$out = "";
		$hi_out = "dest_row_HI:\t.byte\t";
		$lo_out = "dest_row_LO:\t.byte\t";
		$hi = "";
		$lo = "";
		foreach($this->destLocations as $loc){
			$hex = dechex($loc);
			$hi.="$".substr($hex,0,2);
			$lo.="$".substr($hex,2,2);
			$hi.=",";
			$lo.=",";
		}
		$hi_out .= substr($hi, 0, strlen($hi)-1);
		$lo_out .= substr($lo, 0, strlen($lo)-1);
		$out .= $hi_out."\n".$lo_out."\n";
		return $out;
	}
	
	function getSpeedCode(){
		$copy_src = $this->srcLocations;
		$out = "";
		for($i = 0; $i < $this->depth; $i++){
			if($copy_src[$i]!=null){
				$rows_to_write = array_keys($copy_src, $copy_src[$i]);
				
				// now write the speedcode
				foreach($rows_to_write as $row){
					$copy_src[$row] = null;
				}
				// only need one row to read
				$row = $rows_to_write[0];
				$out .= "lda src_row_HI+".$row."\nsta ptr1+1\nlda src_row_LO+".$row."\nsta ptr1\nldy #0\n";
				$a = 2;
				foreach($rows_to_write as $row){
					$out .= "lda dest_row_HI+".$row."\nsta ptr$a+1\nlda dest_row_LO+".$row."\nsta ptr$a\n";
					$a++;
				}
				$out .= ":\n";
				$out .= "lda (ptr1),y\niny\n";
				
				foreach($rows_to_write as $row){
					$out .= "sta $".dechex($this->destLocations[$row]+$a*8)."\n";	
				}
				$out .= "cpy #".($this->width/8)."\nbne :-\n";
				
			}
		}
		return $out;
	}
	function toFile(){
		$fp = fopen("inc/tables.s","w");
		fputs($fp, $this->printSrcTables()."\n".$this->printDestTables());
		fclose($fp);
		$fp = fopen("inc/speedcode.s","w");
		fputs($fp, $this->getSpeedCode());
		fclose($fp);
	}
}

$bitmap = new LandscapeBitmap($gfx_start, $gfx_width, $gfx_height, $field_depth, $perpsective_strength, $starting_chr, $chrset1, $chrset2);
$bitmap->srcLocations();
$bitmap->destLocations();

$bitmap->toFile();
?>