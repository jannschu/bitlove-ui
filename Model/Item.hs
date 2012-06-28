module Model.Item where

import Prelude
import qualified Data.Text as T
import Data.Time
import Data.List (partition)

import Model.Download


data Item = Item {
      itemUser :: T.Text,
      itemSlug :: T.Text,
      itemFeed :: T.Text,
      itemId :: T.Text,
      itemFeedTitle :: Maybe T.Text,
      itemTitle :: T.Text,
      itemLang :: Maybe T.Text,
      itemSummary :: Maybe T.Text,
      itemPublished :: LocalTime,
      itemHomepage :: T.Text,
      itemPayment :: T.Text,
      itemImage :: T.Text,
      itemDownloads :: [Download]
    }
            
groupDownloads :: [Download] -> [Item]
groupDownloads [] = []
groupDownloads (d@(Download {
                     downloadUser = user,
                     downloadHomepage = homepage,
                     downloadTitle = title,
                     downloadItem = id
                   }):ds) =
    let isSimilar (Download { downloadUser = user' })
            | user /= user' = False
        isSimilar d' =
            let homepage' = downloadHomepage d'
                title' = downloadTitle d'
                id' = downloadItem d'
            in ((not $ T.null homepage') && homepage == homepage') ||
               ((not $ T.null title') && title == title') ||
               (id' == id)
        (similar, ds') = partition isSimilar ds
        downloads = d:similar
    in (Item { itemUser = user,
               itemSlug = downloadSlug d,
               itemFeed = downloadFeed d,
               itemId = downloadItem d,
               itemFeedTitle = downloadFeedTitle d,
               itemTitle = downloadTitle d,
               itemLang = downloadLang d,
               itemSummary = downloadSummary d,
               itemPublished = downloadPublished d,
               itemHomepage = downloadHomepage d,
               itemPayment = downloadPayment d,
               itemImage = downloadImage d,
               itemDownloads = downloads
             }) : (groupDownloads ds')