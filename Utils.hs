module Utils ( iso8601, rfc822, localTimeToZonedTime
             , isHex, toHex, fromHex
             , fixUrl, unescapeEntities
             ) where

import Prelude
import Data.Time
import System.Locale
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as BC
import qualified Data.Text as T
import Numeric (readDec, readHex, showHex)
import Data.Char (isHexDigit, isDigit, chr)


iso8601 :: FormatTime t => t -> String
iso8601 time =
    formatTime defaultTimeLocale (iso8601DateFormat $ Just "%H:%M:%S") time ++
    zone
    where zone = case formatTime defaultTimeLocale "%z" time of
                   (sig:digits@(h1:h2:m1:m2))
                     | sig `elem` "+-" &&
                       all isDigit digits ->
                         sig:h1:h2:':':m1:m2
                   _ ->
                     "Z"

rfc822 :: LocalTime -> String
rfc822 = formatTime defaultTimeLocale rfc822DateFormat

localTimeToZonedTime :: TimeZone -> LocalTime -> ZonedTime
localTimeToZonedTime tz =
    utcToZonedTime tz . localTimeToUTC tz

isHex :: BC.ByteString -> Bool
isHex = BC.all isHexDigit

toHex :: B.ByteString -> T.Text
toHex = T.pack . concatMap mapByte . B.unpack
    where mapByte = pad 2 '0' . flip showHex ""
          pad len padding s
              | length s < len = pad len padding $ padding:s
              | otherwise = s

fromHex :: T.Text -> B.ByteString
fromHex = B.pack . hexToWords
  where hexToWords text
          | T.null text = []
          | otherwise = 
            let (hex, text') = T.splitAt 2 text
                w = fst $ head $ readHex $ T.unpack hex
            in w:(hexToWords text')


-- FIXME: rm usage once feeds parser stores URLs properly
fixUrl = unescapeEntities

unescapeEntities :: T.Text -> T.Text
unescapeEntities t =
    case T.break (== '&') t of
      (t, "") ->
          t
      (t', t'') ->
          let (ent, t''') = T.break (== ';') t''
              t'''' | T.null t''' = ""
                    | otherwise = T.tail t'''
              readCodepoints = 
                  case T.unpack ent of
                    ('&':'#':'x':hex)
                        | all isHexDigit hex ->
                            readHex hex
                    ('&':'#':dec)
                        | all isDigit dec ->
                            readDec dec
                    _ ->
                        []
          in case readCodepoints of
               [(codepoint, "")] ->
                   T.concat [ t'
                            , T.singleton (chr codepoint)
                            , unescapeEntities t''''
                            ]
               _ ->
                   T.concat [ t'
                            , ent
                            , unescapeEntities t'''
                            ]
             