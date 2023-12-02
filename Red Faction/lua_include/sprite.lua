
local kFilterMode = {}
kFilterMode.Point                         		  = 0x00000000	-- < Sample the one texel nearest to the sample point.
kFilterMode.Bilinear                      		  = 0x00000001	-- < Sample the four texels nearest the sample point, and blend linearly.

local kWrapMode = {}
kWrapMode.Wrap                            		  = 0x00000000	-- < The integer portion of the input coordinate is discarded, and the fractional portion is used instead. <c>U=U-floorf(U);</c>
kWrapMode.Mirror                          		  = 0x00000001	-- < The input coordinate is "reflected" across the texture boundary. This reflection may occur multiple times until the coordinate falls within the <c>[0..1]</c> range. <c>U=isOdd(floorf(U)) ? 1-fracf(U) : fracf(U)</c>
kWrapMode.ClampLastTexel                  		  = 0x00000002	-- < The input coordinate is clamped to the range <c>[0..1]</c>. <c>U=max(0,min(1,U));</c>
kWrapMode.MirrorOnceLastTexel             		  = 0x00000003	-- < The input coordinate is reflected at most one time and then clamped to the range <c>[0..1]</c>. <c>U=abs(max(-1,min(1,U));</c>
kWrapMode.ClampHalfBorder                 		  = 0x00000004	-- < Similar to kWrapModeClampLastTexel, but if clamping is necessary, the output color will be the border color specified by the Sampler. For this mode, coordinates that are not within half a pixel of the border are considered clamped.
kWrapMode.MirrorOnceHalfBorder            		  = 0x00000005	-- < Similar to kWrapModeMirrorOnceLastTexel, but if clamping is necessary, the output color will be the border color specified by the Sampler. For this mode, coordinates that are not within half a pixel of the border are considered clamped.
kWrapMode.ClampBorder                     		  = 0x00000006	-- < Similar to kWrapModeClampLastTexel, but if clamping is necessary, the output color will be the border color specified by the Sampler. For this mode, coordinates that are outside the range <c>[0..1]</c> are considered clamped.
kWrapMode.MirrorOnceBorder                		  = 0x00000007	-- < Similar to kWrapModeMirrorOnceLastTexel, but if clamping is necessary, the output color will be the border color specified by the Sampler. For this mode, coordinates that are outside the range <c>[0..1]</c> are considered clamped.

local kBlendMultiplier = {}
kBlendMultiplier.Zero                             = 0x00000000  -- < Multiply the associated input by zero.
kBlendMultiplier.One                              = 0x00000001  -- < Multiply the associated input by one.
kBlendMultiplier.SrcColor                         = 0x00000002  -- < Multiply the associated input by the fragment color.
kBlendMultiplier.OneMinusSrcColor                 = 0x00000003  -- < Multiply the associated input by one minus the fragment color.
kBlendMultiplier.SrcAlpha                         = 0x00000004  -- < Multiply the associated input by the fragment alpha.
kBlendMultiplier.OneMinusSrcAlpha                 = 0x00000005  -- < Multiply the associated input by one minus the fragment alpha.
kBlendMultiplier.DestAlpha                        = 0x00000006  -- < Multiply the associated input by the render target alpha.
kBlendMultiplier.OneMinusDestAlpha                = 0x00000007  -- < Multiply the associated input by one minus the render target alpha.
kBlendMultiplier.DestColor                        = 0x00000008  -- < Multiply the associated input by the render target color.
kBlendMultiplier.OneMinusDestColor                = 0x00000009  -- < Multiply the associated input by one minus the render target color.
kBlendMultiplier.SrcAlphaSaturate                 = 0x0000000a  -- < Multiply the associated input by the minimum of 1 or fragment alpha.
kBlendMultiplier.ConstantColor                    = 0x0000000d  -- < Multiply the associated input by the constant color. @see DrawCommandBuffer::setBlendColor()
kBlendMultiplier.OneMinusConstantColor            = 0x0000000e  -- < Multiply the associated input by one minus the constant color. @see DrawCommandBuffer::setBlendColor()
kBlendMultiplier.Src1Color                        = 0x0000000f  -- < Multiply the associated input by a secondary fragment color.
kBlendMultiplier.InverseSrc1Color                 = 0x00000010  -- < Multiply the associated input by one minus a secondary fragment color.
kBlendMultiplier.Src1Alpha                        = 0x00000011  -- < Multiply the associated input by a secondary fragment alpha.
kBlendMultiplier.InverseSrc1Alpha                 = 0x00000012  -- < Multiply the associated input by one minus a secondary fragment alpha.
kBlendMultiplier.ConstantAlpha                    = 0x00000013  -- < Multiply the associated input by the constant color alpha. @see DrawCommandBuffer::setBlendColor()
kBlendMultiplier.OneMinusConstantAlpha            = 0x00000014  -- < Multiply the associated input by one minus the constant color alpha. @see DrawCommandBuffer::setBlendColor()

local kBlendFunc = {}
kBlendFunc.Add                        			  = 0x00000000  -- < The source value is added to the destination value.
kBlendFunc.Subtract                   			  = 0x00000001  -- < The destination value is subtracted from the source value.
kBlendFunc.Min                        			  = 0x00000002  -- < The minimum of the source and destination values is selected.
kBlendFunc.Max                        			  = 0x00000003  -- < The maximum of the source and destination values is selected.
kBlendFunc.ReverseSubtract            			  = 0x00000004  -- < The source value is subtracted from the destination value.

-- Default blending mode, ideal for typical alpha channel embedded into a PNG image.
blendDefaultEquation = {
	kBlendMultiplier.SrcAlpha,					-- src multiplier
	kBlendFunc.Add,		                        -- blend function
	kBlendMultiplier.OneMinusSrcAlpha,		    -- dest multiplier
}

blendConstFadeEquation = {
	kBlendMultiplier.ConstantAlpha,					-- src multiplier
	kBlendFunc.Add,		                  	 	    -- blend function
	kBlendMultiplier.OneMinusConstantAlpha,		    -- dest multiplier
}

return kFilterMode, kWrapMode, kBlendMultiplier, kBlendFunc
