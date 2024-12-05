

import font show *
import bitmap show *
//import pixel-display.true-color show *
//import pixel-display show *
import color-tft show *
import gpio
import io

GC9A01A_INREGEN1 ::= 0xFE  ///< Inter register enable 1
GC9A01A_INREGEN2 ::= 0xEF  ///< Inter register enable 2
GC9A01A1_POWER2 ::= 0xC3   ///< Power Control 2
GC9A01A1_POWER3 ::= 0xC4   ///< Power Control 3
GC9A01A1_POWER4 ::= 0xC9   ///< Power Control 4
GC9A01A_GAMMA1 ::= 0xF0    ///< Set gamma 1
GC9A01A_GAMMA2 ::= 0xF1    ///< Set gamma 2
GC9A01A_GAMMA3 ::= 0xF2    ///< Set gamma 3
GC9A01A_GAMMA4 ::= 0xF3    ///< Set gamma 4
GC9A01A_FRAMERATE ::= 0xE8 ///< Frame rate control

class Gc9a01Tft extends ColorTft:

  constructor 
      device 
      width 
      height 
      --reset/gpio.Pin? 
      --backlight/gpio.Pin?=null 
      --x-offset/int=0 
      --y-offset/int=0 
      --invert-colors/bool=false 
      --flags/int=0:
    
    super device width height --reset=reset --backlight=backlight --x-offset=x-offset --y-offset=y-offset --invert-colors=invert-colors --flags=flags

    send COLOR-TFT-SWRESET_
    // According to documentation, a software reset takes 5ms.
    sleep --ms=5

    backlight-on

    init_


  init_ :
      // Initialization sequence came from some early code provided by the
    // manufacturer. Many of these registers are undocumented, some might
    // be unnecessary, just playing along...
    send  GC9A01A_INREGEN2  
    send  0xEB 0x14 // ?
    send  GC9A01A_INREGEN1
    send  GC9A01A_INREGEN2
    send  0xEB 0x14 // ?
    send  0x84 0x40 // ?
    send  0x85 0xFF // ?
    send  0x86 0xFF // ?
    send  0x87 0xFF // ?
    send  0x88 0x0A // ?
    send  0x89 0x21 // ?
    send  0x8A 0x00 // ?
    send  0x8B 0x80 // ?
    send  0x8C 0x01 // ?
    send  0x8D 0x01 // ?
    send  0x8E 0xFF // ?
    send  0x8F 0xFF // ?
    send  0xB6 0x00 0x00 // ?

    send  COLOR-TFT-MADCTL_ COLOR-TFT-FLIP-X | COLOR-TFT-REVERSE-R-B
    //send COLOR-TFT-MADCTL_ (flags & COLOR-TFT-MADCTL-MASK_)


    if sixteen-bit-mode_:
      send COLOR-TFT-COLMOD_ COLOR-TFT-16-PIXEL-MODE_
      print "16-bit-mode"
    else:
      send COLOR-TFT-COLMOD_ COLOR-TFT-18-PIXEL-MODE_
      print "18-bit-mode"

    send-array  0x90 #[0x08, 0x08, 0x08, 0x08]  // ?
    send  0xBD 0x06 // ?
    send  0xBC 0x00 // 
    send-array  0xFF #[0x60, 0x01, 0x04] // ?
    send  GC9A01A1_POWER2 0x13
    send  GC9A01A1_POWER3 0x13
    send  GC9A01A1_POWER4 0x22
    send  0xBE 0x11 // ?
    send  0xE1 0x10 0x0E // ?
    send-array 0xDF #[0x21, 0x0c, 0x02] // ?
    send-array  GC9A01A_GAMMA1 #[0x45, 0x09, 0x08, 0x08, 0x26, 0x2A ]
    send-array  GC9A01A_GAMMA2 #[0x43, 0x70, 0x72, 0x36, 0x37, 0x6F]
    send-array GC9A01A_GAMMA3 #[0x45, 0x09, 0x08, 0x08, 0x26, 0x2A]
    send-array  GC9A01A_GAMMA4 #[0x43, 0x70, 0x72, 0x36, 0x37, 0x6F ]
    send  0xED 0x1B 0x0B // ?
    send  0xAE 0x77 // ?
    send  0xCD 0x63 // ?
  // Unsure what this line (from manufacturer's boilerplate code) is
  // meant to do, but users reported issues, seems to work OK without:
    send-array 0x70 #[0x07, 0x07, 0x04, 0x0E, 0x0F, 0x09, 0x07, 0x08, 0x03] // ?
    send  GC9A01A_FRAMERATE 0x34
    send-array  0x62 #[0x18, 0x0D, 0x71, 0xED, 0x70, 0x70, 0x18, 0x0F, 0x71, 0xEF, 0x70, 0x70] // ?
    send-array  0x63 #[0x18, 0x11, 0x71, 0xF1, 0x70, 0x70, 0x18, 0x13, 0x71, 0xF3, 0x70, 0x70]// ?            
    send-array  0x64 #[0x28, 0x29, 0xF1, 0x01, 0xF1, 0x00, 0x07] // ?
    send-array 0x66 #[0x3C, 0x00, 0xCD, 0x67, 0x45, 0x45, 0x10, 0x00, 0x00, 0x00] // ?
    send-array  0x67 #[0x00, 0x3C, 0x00, 0x00, 0x00, 0x01, 0x54, 0x10, 0x32, 0x98] // ?
    send-array  0x74 #[0x10, 0x85, 0x80, 0x00, 0x00, 0x4E, 0x00 ]// ?
    send  0x98 0x3e 0x07 // ?

    send  COLOR-TFT-TEON_
    send  COLOR-TFT-INVON_

    send  COLOR-TFT-SLPOUT_ // Exit sleep  
    send  COLOR-TFT-DISPON_ // Display on  
    sleep --ms= 20 


/*
GC9A01A_SWRESET ::= 0x01   ///< Software Reset (maybe, not documented)
GC9A01A_RDDID ::= 0x04     ///< Read display identification information
GC9A01A_RDDST ::= 0x09     ///< Read Display Status
GC9A01A_SLPIN ::= 0x10     ///< Enter Sleep Mode
GC9A01A_SLPOUT ::= 0x11    ///< Sleep Out
GC9A01A_PTLON ::= 0x12     ///< Partial Mode ON
GC9A01A_NORON ::= 0x13     ///< Normal Display Mode ON
GC9A01A_INVOFF ::= 0x20    ///< Display Inversion OFF
GC9A01A_INVON ::= 0x21     ///< Display Inversion ON
GC9A01A_DISPOFF ::= 0x28   ///< Display OFF
GC9A01A_DISPON ::= 0x29    ///< Display ON
GC9A01A_CASET ::= 0x2A     ///< Column Address Set
GC9A01A_RASET ::= 0x2B     ///< Row Address Set
GC9A01A_RAMWR ::= 0x2C     ///< Memory Write
GC9A01A_PTLAR ::= 0x30     ///< Partial Area
GC9A01A_VSCRDEF ::= 0x33   ///< Vertical Scrolling Definition
GC9A01A_TEOFF ::= 0x34     ///< Tearing Effect Line OFF
GC9A01A_TEON ::= 0x35      ///< Tearing Effect Line ON
GC9A01A_MADCTL ::= 0x36    ///< Memory Access Control
GC9A01A_VSCRSADD ::= 0x37  ///< Vertical Scrolling Start Address
GC9A01A_IDLEOFF ::= 0x38   ///< Idle mode OFF
GC9A01A_IDLEON ::= 0x39    ///< Idle mode ON
GC9A01A_COLMOD ::= 0x3A    ///< Pixel Format Set
GC9A01A_CONTINUE ::= 0x3C  ///< Write Memory Continue
GC9A01A_TEARSET ::= 0x44   ///< Set Tear Scanline
GC9A01A_GETLINE ::= 0x45   ///< Get Scanline
GC9A01A_SETBRIGHT ::= 0x51 ///< Write Display Brightness
GC9A01A_SETCTRL ::= 0x53   ///< Write CTRL Display
GC9A01A1_POWER7 ::= 0xA7   ///< Power Control 7
GC9A01A_TEWC ::= 0xBA      ///< Tearing effect width control
GC9A01A1_POWER1 ::= 0xC1   ///< Power Control 1
GC9A01A1_POWER2 ::= 0xC3   ///< Power Control 2
GC9A01A1_POWER3 ::= 0xC4   ///< Power Control 3
GC9A01A1_POWER4 ::= 0xC9   ///< Power Control 4
GC9A01A_RDID1 ::= 0xDA     ///< Read ID 1
GC9A01A_RDID2 ::= 0xDB     ///< Read ID 2
GC9A01A_RDID3 ::= 0xDC     ///< Read ID 3
GC9A01A_FRAMERATE ::= 0xE8 ///< Frame rate control
GC9A01A_SPI2DATA ::= 0xE9  ///< SPI 2DATA control
GC9A01A_INREGEN2 ::= 0xEF  ///< Inter register enable 2
GC9A01A_GAMMA1 ::= 0xF0    ///< Set gamma 1
GC9A01A_GAMMA2 ::= 0xF1    ///< Set gamma 2
GC9A01A_GAMMA3 ::= 0xF2    ///< Set gamma 3
GC9A01A_GAMMA4 ::= 0xF3    ///< Set gamma 4
GC9A01A_IFACE ::= 0xF6     ///< Interface control
GC9A01A_INREGEN1 ::= 0xFE  ///< Inter register enable 1
*/

