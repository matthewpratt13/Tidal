module Sound.Tidal.Control where
{-
    Control.hs - Functions which concern control patterns, which are
    patterns of hashmaps, used for synth control values. See also
    Signal.Control for signal-specific functions.

    Copyright (C) 2022, Alex McLean and contributors

    This library is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this library.  If not, see <http://www.gnu.org/licenses/>.
-}

import           Sound.Tidal.Compose
import           Sound.Tidal.Params  as P
import           Sound.Tidal.Pattern
import           Sound.Tidal.Types

{- |
With `jux`, the original and effected versions of the pattern are
panned hard left and right (i.e., panned at 0 and 1). This can be a
bit much, especially when listening on headphones. The variant `juxBy`
has an additional parameter, which brings the channel closer to the
centre. For example:

@
d1 $ juxBy 0.5 (density 2) $ sound "bd sn:1"
@

In the above, the two versions of the pattern would be panned at 0.25
and 0.75, rather than 0 and 1.
-}
juxBy
  :: Pattern p => p Double
     -> (p ValueMap -> p ValueMap)
     -> p ValueMap
     -> p ValueMap
juxBy n f p = stack [p |+ P.pan (fmap (0.5 -) half_n), f $ p |+ P.pan (fmap (0.5 +) half_n)]
  where half_n = fmap (/2) n

{- | The `jux` function creates strange stereo effects, by applying a
function to a pattern, but only in the right-hand channel. For
example, the following reverses the pattern on the righthand side:

@
d1 $ slow 32 $ jux (rev) $ striateBy 32 (1/16) $ sound "bev"
@

When passing pattern transforms to functions like [jux](#jux) and [every](#every),
it's possible to chain multiple transforms together with `.`, for
example this both reverses and halves the playback speed of the
pattern in the righthand channel:

@
d1 $ slow 32 $ jux ((# speed "0.5") . rev) $ striateBy 32 (1/16) $ sound "bev"
@
-}
jux
  :: Pattern p => (p ValueMap -> p ValueMap)
     -> p ValueMap -> p ValueMap
jux = juxBy (pure 1)

-- juxcut
--   :: (Pattern ValueMap -> Pattern ValueMap)
--      -> Pattern ValueMap -> Pattern ValueMap
-- juxcut f p = stack [p     # P.pan (pure 0) # P.cut (pure (-1)),
--                     f $ p # P.pan (pure 1) # P.cut (pure (-2))
--                    ]

-- juxcut' :: [t -> Pattern ValueMap] -> t -> Pattern ValueMap
-- juxcut' fs p = stack $ map (\n -> ((fs !! n) p |+ P.cut (pure $ 1-n)) # P.pan (pure $ fromIntegral n / fromIntegral l)) [0 .. l-1]
--   where l = length fs

-- {- | In addition to `jux`, `jux'` allows using a list of pattern transform. resulting patterns from each transformation will be spread via pan from left to right.

-- For example:

-- @
-- d1 $ jux' [iter 4, chop 16, id, rev, palindrome] $ sound "bd sn"
-- @

-- will put `iter 4` of the pattern to the far left and `palindrome` to the far right. In the center the original pattern will play and mid left mid right the chopped and the reversed version will appear.

-- One could also write:

-- @
-- d1 $ stack [
--     iter 4 $ sound "bd sn" # pan "0",
--     chop 16 $ sound "bd sn" # pan "0.25",
--     sound "bd sn" # pan "0.5",
--     rev $ sound "bd sn" # pan "0.75",
--     palindrome $ sound "bd sn" # pan "1",
--     ]
-- @

-- -}
-- jux' :: [t -> Pattern ValueMap] -> t -> Pattern ValueMap
-- jux' fs p = stack $ map (\n -> (fs !! n) p |+ P.pan (pure $ fromIntegral n / fromIntegral l)) [0 .. l-1]
--   where l = length fs

-- -- | Multichannel variant of `jux`, _not sure what it does_
-- jux4
--   :: (Pattern ValueMap -> Pattern ValueMap)
--      -> Pattern ValueMap -> Pattern ValueMap
-- jux4 f p = stack [p # P.pan (pure (5/8)), f $ p # P.pan (pure (1/8))]
