$sOutputDir = $Home + "\Desktop\Output"

$sCharsDir = "$sOutputDir\Chars"

$sCombDir = "$sOutputDir\Comb"

$sCombRows = "$sOutputDir\rows"

$sCombTables = "$sOutputDir\tables"

$sImageMagickHome = "C:\ImageMagick"

$sScriptHome = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

$sImageMagickConv = "$sImageMagickHome\convert.exe"

$sMyPath = "mychar.txt"

$pointsize = 10

$rectwidth = 15

$rectheight = 20

$density = 90

$color = [string] "hsb(0,0,0)"

New-Item -ItemType Directory -Force -Path $sOutputDir

New-Item -ItemType Directory -Force -Path $sCharsDir

New-Item -ItemType Directory -Force -Path $sCombDir

New-Item -ItemType Directory -Force -Path $sCombRows

New-Item -ItemType Directory -Force -Path $sCombTables

Function conjoinRange( $begin, $end )
{
	If( Test-Path $sCombRows ) { Remove-Item -Recurse -Force $sCombRows }
	
	New-Item -ItemType Directory -Force -Path $sCombRows
	
	$rows = 1;
			
	for( $i = $begin; $i -le $end; $i += 50 )
	{	
		$span = $end - $begin
		
		if( $span -ge 50 ) { $span = 50 }
		
		if( $span -ge 50 )
		{
			$sParamList = " +append ";
			
			for( $z = 0; $z -lt $span; $z++ )
			{
				$sCurPNG = $i + $z;

				$sCurPNGFileName = [string]"{0:X0000}" -f $sCurPNG + ".png"	
				
				if( Test-Path "$sCharsDir\$sCurPNGFileName" )
				{
					$sParamList = $sParamList + " $sCharsDir\$sCurPNGFileName"
				}
				else
				{
					$sParamList = $sParamList + " $sCharsDir\space.png"
				}
			}
			
			& cmd /c "$sImageMagickConv $sParamList $sCombRows\$rows.png"
			
			$rows++;
		}
		else
		{
			$sParamList = " +append ";
			
			for( $z = 0; $z -le $span; $z++ )
			{
				$sCurPNG = $i + $z;

				$sCurPNGFileName = [string]"{0:X0000}" -f $sCurPNG + ".png"	

				if( Test-Path "$sCharsDir\$sCurPNGFileName" )
				{
					$sParamList = $sParamList + " $sCharsDir\$sCurPNGFileName"
				}
				else
				{
					$sParamList = $sParamList + " $sCharsDir\space.png"
				}
			}
			
			& cmd /c "$sImageMagickConv $sParamList $sCombRows\$rows.png"
		}
	}
	
	$vertcount = 1;
	
	$sParamList = " -append ";
	
    $sTableName = getTableName $begin $end
	
	$sTableName = [string]$pointsize + "pt_" + $sTableName
	
    If( $rows -gt 1 )
    {
	    Do
	    {
            $vertnext = $vertcount + 1;
		    & cmd /c "$sImageMagickConv $sParamList $sCombRows\$vertcount.png $sCombRows\$vertnext.png $sCombTables\$sTableName"
		    $vertcount++;
	    }
	    Until( $vertcount -le $rows )
    }
    else
    {

        $vertnext = $vertcount + 1;
		& cmd /c "$sImageMagickConv $sParamList $sCombRows\$vertcount.png $sCombTables\$sTableName"
		$vertcount++;

    }
}

Function outputPNG( $begin, $end, $font )
{
	$sImageMagickArgs = ""
	
	for ( $i = $begin; $i -le $end; $i++ )
	{
		$sCurChar = [char]::ConvertFromUtf32($i)
		
		If($sCurChar -contains ' ')
		{
		
		}
		ElseIf($sCurChar -contains '')
		{
		
		}
		Else
		{
			If( Test-Path $sMyPath ) { Remove-Item -Recurse -Force $sMyPath }

			$MyArray = [string]$sCurChar
			
			$sNewPath = $sScriptHome+"\"+$sMyPath
			
			$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding( $False )
			
			[System.IO.File]::WriteAllText( $sNewPath, $MyArray, $Utf8NoBomEncoding)

			$sCurFileName = [string]"{0:X0000}" -f $i+".png"
			
			$sImageMagickArgs = @('-background', 'transparent', 
						'-fill', $color, 
						'-font', "$font",
						'-density',$density,
						'-pointsize', $pointsize,
						'-gravity', 'center',
                        '-size', "$rectwidth x $rectheight"
						#'-annotate','0',
						'label:@mychar.txt',
						"$sCharsDir\$sCurFileName")
							
			Write-Host $sImageMagickConv $sImageMagickArgs
			
			& $sImageMagickConv $sImageMagickArgs
		}
	
	}
	 
	$MyArray = [string]" "
	
	$sNewPath = $sScriptHome+"\"+$sMyPath
	
	$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding( $False )
	
	[System.IO.File]::WriteAllText( $sNewPath, $MyArray, $Utf8NoBomEncoding )

	$sCurFileName = "space.png"
	
	$sImageMagickArgs = @('-background', 'transparent', 
				'-fill', $color, 
				'-font', "$font",
				'-density',$density,
				'-pointsize', $pointsize,
				'-gravity', 'center',
				'-size', "$rectwidth x $rectheight"
				#'-annotate','0',
				'label:@mychar.txt',
				"$sCharsDir\$sCurFileName")
					
	Write-Host $sImageMagickConv $sImageMagickArgs
	
	& $sImageMagickConv $sImageMagickArgs
			
	conjoinRange $begin $end
}

Function getTableName( $begin, $end )
{
    switch ( $begin )
    {
		0x0020 { return "LatinBasic.png" }
		0x00A0 { return "LatinSupplement.png" }
		0x0100 { return "LatinExtendedA.png" }
		0x0180 { return "LatinExtendedB.png" }
		0x0250 { return "IPAEXtensions.png" }
		0x02B0 { return "SpacingModifierLetters.png" }
		0x0300 { return "CombiningDiacriticalMarks.png" }
		0x0370 { return "Greek_Coptic.png" }
		0x0400 { return "Cyrillic.png" }
		0x0500 { return "CyrillicSupplementary.png" }
		0x0530 { return "Armenian.png" }
		0x0590 { return "Hebrew.png" }
		0x0600 { return "Arabic.png" }
		0x0700 { return "Syriac.png" }
		0x0780 { return "Thaana.png" }
		0x0900 { return "Devanagari.png" }
		0x0980 { return "Bengali.png" }
		0x0A00 { return "Gurmukhi.png" }
		0x0A80 { return "Gujarati.png" }
		0x0B00 { return "Oriya.png" }
		0x0B80 { return "Tamil.png" }
		0x0C00 { return "Telugu.png" }
		0x0C80 { return "Kannada.png" }
		0x0D00 { return "Malayalam.png" }
		0x0D80 { return "Sinhala.png" } 		
		0x0E00 { return "Thai.png" }  	
		0x0E80 { return "Malayalam.png" }		
		0x0F00 { return "Lao.png" }		
		0x1000 { return "Myanmar.png" }	
		0x10A0 { return "Georgian.png" } 		
		0x1100 { return "HangulJamo.png" }			
		0x1200 { return "Ethiopic.png" } 		
		0x13A0 { return "Cherokee.png" } 	
		0x1400 { return "UnifiedCanadianAboriginalSyllabics.png" }		
		0x1680 { return "Ogham.png" }			
		0x16A0 { return "Runic.png" }				
		0x1700 { return "Tagalog.png" }				
		0x1720 { return "Hanunoo.png" }					
		0x1740 { return "Buhid.png" }				
		0x1760 { return "Tagbanwa.png" } 					
		0x1780 { return "Khmer.png" }					
		0x1800 { return "Mongolian.png" }				
		0x1900 { return "Limbu.png" }					
		0x1950 { return "TaiLe.png" }				
		0x19E0 { return "KhmerSymbols.png" }				
		0x1D00 { return "PhoneticExtensions.png" }						
		0x1E00 { return "LatinExtendedAdditional.png" }							
		0x1F00 { return "GreekExtended.png" }							
		0x2000 { return "GeneralPunctuation.png" }					
		0x2070 { return "SuperscriptsandSubscripts.png" }					
		0x20A0 { return "CurrencySymbols.png" }						
		0x20D0 { return "CombiningDiacriticalMarksforSymbols.png" }					
		0x2100 { return "LetterlikeSymbols.png" } 					
		0x2150 { return "NumberForms.png" }					
		0x2190 { return "Arrows.png" } 					
		0x2200 { return "MathematicalOperators.png" }					
		0x2300 { return "MiscellaneousTechnical.png" }					
		0x2400 { return "ControlPictures.png" }					
		0x2440 { return "OpticalCharacterRecognition.png" }				
		0x2460 { return "EnclosedAlphanumerics.png" }				
		0x2500 { return "BoxDrawing.png" }					
		0x2580 { return "BlockElements.png" } 					
		0x25A0 { return "GeometricShapes.png" }					
		0x2600 { return "MiscellaneousSymbols.png" }  					
		0x2700 { return "Dingbats.png" }  					
		0x27C0 { return "MiscellaneousMathematicalSymbols-A.png" }  					
		0x27F0 { return "SupplementalArrows-A.png" } 					
		0x2800 { return "BraillePatterns.png" }  					
		0x2900 { return "SupplementalArrows-B.png" }  					
		0x2980 { return "MiscellaneousMathematicalSymbols-B.png" } 					
		0x2A00 { return "SupplementalMathematicalOperators.png" }  					
		0x2B00 { return "MiscellaneousSymbolsandArrows.png" }				
		0x2E80 { return "CJKRadicalsSupplement.png" }			
		0x2F00 { return "KangxiRadicals.png" }  			
		0x2FF0 { return "IdeographicDescriptionCharacters.png" }			
		0x3000 { return "CJKSymbolsandPunctuation.png" }			
		0x3040 { return "Hiragana.png" }			
		0x30A0 { return "Katakana.png" }			
		0x3100 { return "Bopomofo.png" }			
		0x3130 { return "Malayalam.png" }			
		0x3190 { return "HangulCompatibilityJamo.png" }			
		0x31A0 { return "BopomofoExtended.png" }			
		0x31F0 { return "KatakanaPhoneticExtensions.png" }			
		0x3200 { return "EnclosedCJKLettersandMonths.png" }			
		0x3300 { return "CJKCompatibility.png" }			
		0x3400 { return "CJKUnifiedIdeographsExtensionA.png" }			
		0x4DC0 { return "YijingHexagramSymbols.png" }			
		0x4E00 { return "CJKUnifiedIdeographs.png" }			
		0xA000 { return "YiSyllables.png" }						
		0xA490 { return "YiRadicals.png" }						
		0xAC00 { return "HangulSyllables.png" } 			
		0xD800 { return "HighSurrogates.png" }					
		0xDB80 { return "HighPrivateUseSurrogates.png" }					
		0xDC00 { return "LowSurrogates.png" }						
		0xE000 { return "PrivateUseArea.png" }						
		0xF900 { return "CJKCompatibilityIdeographs.png" }			
		0xFB00 { return "AlphabeticPresentationForms.png" }					
		0xFB50 { return "ArabicPresentationForms-A.png" }					
		0xFE00 { return "VariationSelectors.png" }						
		0xFE20 { return "CombiningHalfMarks.png" }							
		0xFE30 { return "CJKCompatibilityForms.png" }			
		0xFE50 { return "SmallFormVariants.png" }			
		0xFE70 { return "ArabicPresentationForms-B.png" }			
		0xFF00 { return "HalfwidthandFullwidthForms.png" }					
		0xFFF0 { return "Specials.png" }						
		0x10000 { return "LinearBSyllabary.png" }					
		0x10080 { return "LinearBIdeograms.png" }					
		0x10100 { return "AegeanNumbers.png" }							
		0x10300 { return "OldItalic.png" }				
		0x10330 { return "Gothic.png" }			
		0x10380 { return "Ugaritic.png" }			
		0x10400 { return "Deseret.png" }				
		0x10450 { return "Shavian.png" }						
		0x10480 { return "Osmanya.png" }				
		0x10800 { return "CypriotSyllabary.png" }				
		0x1D000 { return "ByzantineMusicalSymbols.png" }				
		0x1D100 { return "MusicalSymbols.png" } 				
		0x1D300 { return "TaiXuanJingSymbols.png" }			
		0x1D400 { return "MathematicalAlphanumericSymbols.png" }				
		0x20000 { return "CJKUnifiedIdeographsExtensionB.png" }			
		0x2F800 { return "CJKCompatibilityIdeographsSupplement.png" }			
		0xE0000 { return "Tags.png" }			
    }
}
	
	outputPNG 0x0020 0x007F "Segoe-UI"							    #Basic Latin OK DEC_32_127
	outputPNG 0x00A0 0x00FF "Segoe-UI" 								#Latin-1 Supplement OK 	DEC_160_255
	outputPNG 0x0100 0x017F "Segoe-UI" 								#Latin Extended-A OK DEC_256_383
	outputPNG 0x0180 0x024F "Segoe-UI"  							#Latin Extended-B OK DEC_384_591
	outputPNG 0x0250 0x02AF "Segoe-UI"  							#IPA Extensions OK DEC_592_687
	outputPNG 0x02B0 0x02FF "Segoe-UI"  							#Spacing Modifier Letters OK
	outputPNG 0x0300 0x036F "Segoe-UI"  							#Combining Diacritical Marks OK
	outputPNG 0x0370 0x03FF "Segoe-UI"  							#Greek and Coptic OK
	outputPNG 0x0400 0x04FF "Segoe-UI"  							#Cyrillic OK
	outputPNG 0x0500 0x052F "Segoe-UI"  							#Cyrillic Supplementary OK
	outputPNG 0x0530 0x058F "Segoe-UI"  							#Armenian OK
	outputPNG 0x0590 0x05FF "Segoe-UI"  							#Hebrew OK
	outputPNG 0x0600 0x06FF "Segoe-UI"						        #Arabic OK
	outputPNG 0x0700 0x074F "Noto-Sans-Syriac-Eastern"  			#Syriac OK
	outputPNG 0x0780 0x07BF "Noto-Sans-Thaana"  					#Thaana OK
	outputPNG 0x0900 0x097F "Noto-Sans-Devanagari"  				#Devanagari OK
	outputPNG 0x0980 0x09FF "Noto-Sans-Bengali"  					#Bengali OK
	outputPNG 0x0A00 0x0A7F "Noto-Sans-Gurmukhi"  					#Gurmukhi OK
	outputPNG 0x0A80 0x0AFF "Noto-Sans-Gujarati"  					#Gujarati OK
	outputPNG 0x0B00 0x0B7F "Noto-Sans-Oriya"  					    #Oriya OK
	outputPNG 0x0B80 0x0BFF "Noto-Sans-Tamil"  					    #Tamil OK
	outputPNG 0x0C00 0x0C7F "Noto-Sans-Telugu"  					#Telugu OK
	outputPNG 0x0C80 0x0CFF "Noto-Sans-Kannada"  					#Kannada OK
	outputPNG 0x0D00 0x0D7F "Noto-Sans-Malayalam"  				    #Malayalam OK
	outputPNG 0x0D80 0x0DFF "Noto-Sans-Sinhala"  					#Sinhala OK
	outputPNG 0x0E00 0x0E7F "Noto-Sans-Thai"  						#Thai OK
	outputPNG 0x0E80 0x0EFF "Noto-Sans-Lao"  						#Lao OK
	outputPNG 0x0F00 0x0FFF "Noto-Sans-Tibetan"  					#Tibetan OK
	outputPNG 0x1000 0x109F "Noto-Sans-Myanmar"  					#Myanmar OK
	outputPNG 0x10A0 0x10FF "Noto-Serif-Georgian"  				    #Georgian OK
	outputPNG 0x1100 0x11FF "Batang"  								#Hangul Jamo OK
	outputPNG 0x1200 0x137F "Noto-Sans-Ethiopic"  					#Ethiopic OK
	outputPNG 0x13A0 0x13FF "Noto-Sans-Cherokee"  					#Cherokee OK
	outputPNG 0x1400 0x167F "Noto-Sans-Canadian-Aboriginal"  		#Unified Canadian Aboriginal Syllabics OK
	outputPNG 0x1680 0x169F "Noto-Sans-Ogham"  					    #Ogham OK
	outputPNG 0x16A0 0x16FF "Noto-Sans-Runic"  					    #Runic OK
	outputPNG 0x1700 0x171F "Noto-Sans-Tagalog"  					#Tagalog OK
	outputPNG 0x1720 0x173F "Noto-Sans-Hanunoo"  					#Hanunoo OK
	outputPNG 0x1740 0x175F "Noto-Sans-Buhid"  					    #Buhid OK
	outputPNG 0x1760 0x177F "Noto-Sans-Tagbanwa"  					#Tagbanwa OK
	outputPNG 0x1780 0x17FF "Noto-Serif-Khmer"  					#Khmer OK
	outputPNG 0x1800 0x18AF "Noto-Sans-Mongolian"  				    #Mongolian OK
	outputPNG 0x1900 0x194F "Noto-Sans-Limbu"  					    #Limbu OK
	outputPNG 0x1950 0x197F "Noto-Sans-New-Tai-Lue"  				#Tai Le OK
	outputPNG 0x19E0 0x19FF "Noto-Serif-Khmer"  					#Khmer Symbols OK
	outputPNG 0x1D00 0x1D7F "Segoe-UI"  							#Phonetic Extensions OK
	outputPNG 0x1E00 0x1EFF "Segoe-UI"  							#Latin Extended Additional OK
	outputPNG 0x1F00 0x1FFF "Segoe-UI"  							#Greek Extended OK
	outputPNG 0x2000 0x206F "Segoe-UI"  							#General Punctuation OK
	outputPNG 0x2070 0x209F "Segoe-UI"  							#Superscripts and Subscripts OK
	outputPNG 0x20A0 0x20CF "Segoe-UI"  							#Currency Symbols OK
	outputPNG 0x20D0 0x20FF "Noto-Sans-Symbols"  					#Combining Diacritical Marks for Symbols OK
	outputPNG 0x2100 0x214F "Noto-Sans-Symbols"  					#Letterlike Symbols OK
	outputPNG 0x2150 0x218F "Noto-Sans-Symbols"  					#Number Forms OK
	outputPNG 0x2190 0x21FF "Noto-Sans-Symbols"  					#Arrows OK
	outputPNG 0x2200 0x22FF "Noto-Sans-Symbols"  					#Mathematical Operators OK
	outputPNG 0x2300 0x23FF "Noto-Sans-Symbols"  					#Miscellaneous Technical OK
	outputPNG 0x2400 0x243F "Noto-Sans-Symbols"  					#Control Pictures OK
	outputPNG 0x2440 0x245F "Noto-Sans-Symbols"  					#Optical Character Recognition OK
	outputPNG 0x2460 0x24FF "Noto-Sans-Symbols"  					#Enclosed Alphanumerics OK
	outputPNG 0x2500 0x257F "Noto-Sans-Symbols"  					#Box Drawing OK
	outputPNG 0x2580 0x259F "Noto-Sans-Symbols"   					#Block Elements OK
	outputPNG 0x25A0 0x25FF "Noto-Sans-Symbols"   					#Geometric Shapes OK
	outputPNG 0x2600 0x26FF "Noto-Sans-Symbols"   					#Miscellaneous Symbols OK
	outputPNG 0x2700 0x27BF "Noto-Sans-Symbols"   					#Dingbats OK
	outputPNG 0x27C0 0x27EF "Noto-Sans-Symbols"   					#Miscellaneous Mathematical Symbols-A OK
	outputPNG 0x27F0 0x27FF "Noto-Sans-Symbols"   					#Supplemental Arrows-A OK
	outputPNG 0x2800 0x28FF "Noto-Sans-Symbols"   					#Braille Patterns OK
	outputPNG 0x2900 0x297F "Noto-Sans-Symbols"   					#Supplemental Arrows-B OK
	outputPNG 0x2980 0x29FF "Noto-Sans-Symbols"   					#Miscellaneous Mathematical Symbols-B OK
	outputPNG 0x2A00 0x2AFF "Noto-Sans-Symbols"   					#Supplemental Mathematical Operators OK
	outputPNG 0x2B00 0x2BFF "Noto-Sans-Symbols"   					#Miscellaneous Symbols and Arrows OK
	outputPNG 0x2E80 0x2EFF "Noto-Sans-CJK-SC-Black"   			    #CJK Radicals Supplement OK
	outputPNG 0x2F00 0x2FDF "Noto-Sans-CJK-SC-Black"   			    #Kangxi Radicals OK
	outputPNG 0x2FF0 0x2FFF "Noto-Sans-CJK-SC-Black"   			    #Ideographic Description Characters OK
	outputPNG 0x3000 0x303F "Noto-Sans-CJK-SC-Black"   			    #CJK Symbols and Punctuation OK
	outputPNG 0x3040 0x309F "Noto-Sans-CJK-JP-Regular"   			#Hiragana OK
	outputPNG 0x30A0 0x30FF "Noto-Sans-CJK-JP-Regular"   			#Katakana OK
	outputPNG 0x3100 0x312F "Noto-Sans-CJK-SC-Black"   			    #Bopomofo OK
	outputPNG 0x3130 0x318F "Noto-Sans-CJK-KR-Black"   			    #Hangul Compatibility Jamo OK
	outputPNG 0x3190 0x319F "Noto-Sans-CJK-SC-Black"   			    #Kanbun OK
	outputPNG 0x31A0 0x31BF "Noto-Sans-CJK-SC-Black"   			    #Bopomofo Extended OK
	outputPNG 0x31F0 0x31FF "Noto-Sans-CJK-SC-Black"   			    #Katakana Phonetic Extensions OK
	outputPNG 0x3200 0x32FF "Noto-Sans-CJK-SC-Black"   			    #Enclosed CJK Letters and Months OK
	outputPNG 0x3300 0x33FF "Noto-Sans-CJK-SC-Black"   			    #CJK Compatibility OK
	outputPNG 0x3400 0x4DBF "Noto-Sans-CJK-SC-Black"   			    #CJK Unified Ideographs Extension A OK
	outputPNG 0x4DC0 0x4DFF "Noto-Sans-CJK-SC-Black"   			    #Yijing Hexagram Symbols OK
	outputPNG 0x4E00 0x9FFF "Noto-Sans-CJK-SC-Black"   			    #CJK Unified Ideographs OK
	outputPNG 0xA000 0xA48F "Noto-Sans-Yi"   						#Yi Syllables OK
	outputPNG 0xA490 0xA4CF "Noto-Sans-Yi"   						#Yi Radicals OK
	outputPNG 0xAC00 0xD7AF "Noto-Sans-CJK-KR-Black"   			    #Hangul Syllables OK
	outputPNG 0xD800 0xDB7F "Noto-Sans-Symbols"   					#High Surrogates OMIT
	outputPNG 0xDB80 0xDBFF "Noto-Sans-Symbols"   					#High Private Use Surrogates OMIT
	outputPNG 0xDC00 0xDFFF "Segoe-UI"   							#Low Surrogates OMIT
	outputPNG 0xE000 0xF8FF "Segoe-UI"   							#Private Use Area OMIT
	outputPNG 0xF900 0xFAFF "Noto-Sans-CJK-SC-Black"   			    #CJK Compatibility Ideographs OK
	outputPNG 0xFB00 0xFB4F "Segoe-UI"   							#Alphabetic Presentation Forms OK
	outputPNG 0xFB50 0xFDFF "Unifont"   							#Arabic Presentation Forms-A OK
	outputPNG 0xFE00 0xFE0F "Unifont"   							#Variation Selectors OK
	outputPNG 0xFE20 0xFE2F "Unifont"   							#Combining Half Marks OK
	outputPNG 0xFE30 0xFE4F "Noto-Sans-CJK-SC-Black"   			    #CJK Compatibility Forms OK
	outputPNG 0xFE50 0xFE6F "Lucida-Sans-Unicode"   				#Small Form Variants OMIT
	outputPNG 0xFE70 0xFEFF "Segoe-UI"  							#Arabic Presentation Forms-B OK
	outputPNG 0xFF00 0xFFEF "Unifont"   							#Halfwidth and Fullwidth Forms OK
	outputPNG 0xFFF0 0xFFFF "Unifont"   							#Specials OMIT
	outputPNG 0x10000 0x1007F "Linear-B"   						    #Linear B Syllabary OK
	outputPNG 0x10080 0x100FF "Linear-B"   						    #Linear B Ideograms OK
	outputPNG 0x10100 0x1013F "Aegean"   							#Aegean Numbers OK
	outputPNG 0x10300 0x1032F "MPH-2B-Damase"   					#Old Italic OK
	outputPNG 0x10330 0x1034F "Noto-Sans-Gothic"   				    #Gothic OK
	outputPNG 0x10380 0x1039F "Noto-Sans-Ugaritic"   				#Ugaritic OK
	outputPNG 0x10400 0x1044F "Noto-Sans-Deseret"   				#Deseret OK
	outputPNG 0x10450 0x1047F "Shavian"   							#Shavian OK
	outputPNG 0x10480 0x104AF "Noto-Sans-Osmanya"   				#Osmanya OK
	outputPNG 0x10800 0x1083F "Noto-Sans-Cypriot"   				#Cypriot Syllabary OK
	outputPNG 0x1D000 0x1D0FF "Byzantine-Normal"   				    #Byzantine Musical Symbols OK
	outputPNG 0x1D100 0x1D1FF "Noto-Sans-Symbols"   				#Musical Symbols OK
	outputPNG 0x1D300 0x1D35F "Noto-Sans-New-Tai-Lue"   			#Tai Xuan Jing Symbols
	outputPNG 0x1D400 0x1D7FF "Noto-Sans-Symbols"   				#Mathematical Alphanumeric Symbols OK
	outputPNG 0x20000 0x2A6DF "Noto-Sans-CJK-SC-Black"   			#CJK Unified Ideographs Extension B
	outputPNG 0x2F800 0x2FA1F "Noto-Sans-CJK-SC-Black"   			#CJK Compatibility Ideographs Supplement
	outputPNG 0xE0000 0xE007F "Noto-Sans-Symbols"   				#Tags DEC_917504_917631 OMIT