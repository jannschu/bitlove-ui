{-# LANGUAGE RankNTypes #-}
module Handler.DownloadFeeds where
-- TODO: absolute links!

import qualified Data.Text as T
import Data.Maybe
import Data.Time.Format
import System.Locale

import qualified Model
import Import


typeTorrent :: T.Text
typeTorrent = "application/x-bittorrent"

nsAtom :: T.Text
nsAtom = "http://www.w3.org/2005/Atom"

torrentLink d = TorrentFileR 
                (downloadUser d) 
                (downloadSlug d) 
                (TorrentName $ downloadName d)

data FeedParameters = Parameters {
      pTitle :: T.Text,
      pImage :: T.Text,
      pLink :: Route App
    }

class RepFeed c where
  renderFeed :: FeedParameters -> [Item] -> Handler c
  
  renderFeed' :: FeedParameters -> [Download] -> Handler c
  renderFeed' params downloads = renderFeed params $
                                 groupDownloads downloads
  
newtype RepRss = RepRss Content

instance HasReps RepRss where
    chooseRep (RepRss content) _cts =
      return (typeRss, content)
      
-- TODO: No ISO8601 perhaps
instance RepFeed RepRss where
  renderFeed params items = do
    let itemLink = "TODO" :: T.Text
        image = pImage params
    RepRss `fmap` hamletToContent [xhamlet|
<rss version="2.0"
     xmlns:atom=#{nsAtom}>
  <channel>
    <title>#{pTitle params}
    <link>@{pLink params}
    $if not (T.null image)
      <image>
        <url>#{image}
    $forall item <- items
      <item>
        <title>#{itemTitle item}
        <link>#{itemLink}
        <guid isPermaLink="true">#{itemLink}
        <published>#{iso8601 (itemPublished item)}
        $if not (T.null $ itemImage item)
            <image>
              <url>#{itemImage item}
        $if not (T.null $ itemPayment item)
            <atom:link rel="payment"
                       href=#{itemPayment item}
                       >
        $forall d <- itemDownloads item
            <link rel="enclosure"
                  type=#{typeTorrent}
                  size=#{downloadSize d}
                  href=@{torrentLink d}
                  >
    |]

newtype RepAtom = RepAtom Content

instance HasReps RepAtom where
    chooseRep (RepAtom content) _cts =
      return (typeAtom, content)
      
instance RepFeed RepAtom where
  renderFeed params items = do
    let itemLink = "TODO" :: T.Text
        image = pImage params
    RepAtom `fmap` hamletToContent [xhamlet|
<feed version="1.0"
      xmlns=#{nsAtom}>
    <title>#{pTitle params}
    <link rel="alternate"
          type="text/html"
          href=@{pLink params}
          >
    <id>@{pLink params}
    $if not (T.null image)
        <link rel="icon"
              href=#{image}
              >
    $forall item <- items
        <title>#{itemTitle item}
        <link rel="alternate"
              type="text/html"
              href=#{itemLink}
              >
        <id>#{itemLink}
        <published>#{iso8601 (itemPublished item)}
        $if not (T.null $ itemImage item)
            <link rel="icon"
                  href=#{itemImage item}
                  >

        $if not (T.null $ itemPayment item)
            <link rel="payment"
                  href=#{itemPayment item}
                  >
        $forall d <- itemDownloads item
            <link rel="enclosure"
                  type=#{typeTorrent}
                  size=#{downloadSize d}
                  href=@{torrentLink d}
                  >
    |]



getNew :: RepFeed a => Handler a
getNew = withDB (Model.recentDownloads 25) >>=
         renderFeed' Parameters {
                           pTitle = "Bitlove: New",
                           pLink = NewR,
                           pImage = ""
                         }

getNewRssR :: Handler RepRss
getNewRssR = getNew

getNewAtomR :: Handler RepAtom
getNewAtomR = getNew

getTop :: RepFeed a => Handler a
getTop = withDB (Model.popularDownloads 25) >>=
         renderFeed' Parameters {
                           pTitle = "Bitlove: Top",
                           pLink = TopR,
                           pImage = ""
                         }
         
getTopRssR :: Handler RepRss
getTopRssR = getTop

getTopAtomR :: Handler RepAtom
getTopAtomR = getTop

getFeedDownloads :: RepFeed a => Text -> Text -> Handler a
getFeedDownloads user feed = 
    withDB $ undefined
    
getFeedDownloadsRssR :: Text -> Text -> Handler RepRss
getFeedDownloadsRssR = getFeedDownloads

getFeedDownloadsAtomR :: Text -> Text -> Handler RepAtom
getFeedDownloadsAtomR = getFeedDownloads