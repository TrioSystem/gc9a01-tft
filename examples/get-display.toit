// Copyright (C) 2022 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import gpio
import spi
import color-tft show *
import gc9a01-tft show *
import pixel-display show *


                    //MHz  x   y   xoff yoff sda clock  cs   dc  reset  backlight invert
ESP32-2424S012 ::= [  40, 240, 240, 0,  0,   7,   6,    10,  2,   null,   3,  false, COLOR_TFT_16_BIT_MODE | COLOR-TFT-FLIP-X  ]


// COLOR-TFT-FLIP-X  // Flip across the X axis.
// COLOR-TFT-FLIP-Y   // Flip across the Y axis.
// COLOR-TFT-FLIP-XY   // Reverse the X and Y axes.
// COLOR-TFT-REVERSE-R-B   // Reverse the red and blue channels. | COLOR-TFT-REVERSE-R-B



 /* ESP32-2424S012
                
      Display (GC9A01):

      clk = 6
      mosi = 7
      dc = 2
      cs = 10
      backlight = 3

      Touch (CST816D):

      sda = 4
      scl = 5
      int = 0
      rst = 1
      I2C_ADDR_CST816D 0x15
               
  */




pin-for num/int? -> gpio.Pin?:
  if num == null: return null
  if num < 0:
    return gpio.InvertedPin (gpio.Pin -num)
  return gpio.Pin num

get-display setting/List -> PixelDisplay:
  hz            := 1_000_000 * setting[0]
  width         := setting[1]
  height        := setting[2]
  x-offset      := setting[3]
  y-offset      := setting[4]
  mosi          := pin-for setting[5]
  clock         := pin-for setting[6]
  cs            := pin-for setting[7]
  dc            := pin-for setting[8]
  reset         := pin-for setting[9]
  backlight     := pin-for setting[10]
  invert-colors := setting[11]
  flags         := setting[12]

  print "Hz $hz"         
  print "with $width"      
  print "hight $height"        
  print "x-off $x-offset"      
  print "y-off $y-offset"      
  print "mosi $mosi.num"          
  print "clock $clock.num"         
  print "cs $cs.num"            
  print "dc $dc.num"            
  print "reset $reset"         
  print "backlight $backlight"    
  print "invert-colors $invert-colors" 
  print "flags $flags"

  print "start bus"

  bus := spi.Bus
    --mosi=mosi
    --clock=clock

  device := bus.device
    --cs=cs
    --dc=dc
    --frequency=hz

  driver := Gc9a01Tft device width height
    --reset=reset
    --backlight=backlight
    --x-offset=x-offset
    --y-offset=y-offset
    --flags=flags
    --invert-colors=invert-colors

  tft := PixelDisplay.true-color driver

  return tft
