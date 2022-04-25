# Smart Bookmarks(Query Bookmarks)

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Basics](#basics)
- [Places query URIs](#places-query-uris)
- [Query parameters](#query-parameters)
- [Query operators](#query-operators)

<!-- markdown-toc end -->

## Basics
**Related Docs**
- [Support Mozilla: Restore the default Smart Bookmarks Folders](https://support.mozilla.org/en-US/kb/restore-default-smart-bookmarks-folders) (Not works)
- [Smart Bookmarks. A quick guide.](https://www.reddit.com/r/firefox/comments/2i4qcy/smart_bookmarks_a_quick_guide/)
- [Smart Bookmarks. A quick guide. (extended)](https://www.reddit.com/r/firefox/comments/fvcw96/query_bookmarks_smart_bookmarks_a_quick_guide/)
- [How to Create Custom Smart Bookmarks Folders in Firefox](https://www.howtogeek.com/111820/how-to-create-custom-smart-bookmarks-folders-in-firefox/)
- [MDN: Places query URIs(Archived)](https://web.archive.org/web/20210531033430/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Places_query_URIs)
- [UDN: Querying Places](https://udn.realityripple.com/docs/Mozilla/Tech/Places/Querying)
- [mozillaZine: Places query syntax](https://forums.mozillazine.org/viewtopic.php?p=3260477)

**Explanation**

Firefox 3 switched to "places" sqlite database as a main bookmarks and history container. (Previously used [MDN: Mork file format(Achieved)](https://web.archive.org/web/20120509214427/https://developer.mozilla.org/en/Mork_Structure))

You can get a glimpse of SQL query power by using serialized `places:` query strings.

Simple strings that can be added to your bookmarks that will perform queries over database.

**Current State**

`browser.places.smartBookmarksVersion` does not work.

There is [no search in the source code](https://searchfox.org/mozilla-central/search?q=browser.places.smartBookmarksVersion&path=&case=false&regexp=false), and you can see that [the code in ESR 60](https://searchfox.org/mozilla-esr60/search?q=browser.places.smartBookmarksVersion&path=&case=false&regexp=false) has been removed.

Place query URIS related information was also removed from MDN, but fortunately it is still operable.

## Places query URIs

This article describes the parameters you can use when constructing `place` URIs. These URIs perform [Places](https://udn.realityripple.com/docs/Mozilla/Tech/Places) queries.

You can use a `place` URI as a bookmark. For example, if you right-click on the toolbar and choose "New Bookmark," you can enter a `place` URI there to create a new query on your toolbar that, when clicked, will reveal a popup containing the results of the query.

The following `place` URI is used to implement the "Most Visited" smart bookmark in the default set of smart bookmarks created when you first start using Firefox 3:

```
place:queryType=0&sort=8&maxResults=10
```

The parameters used in this query are:

- `queryType=0`: This indicates that the query should look only at the user's history and not at bookmarks.
- `sort=8`: The `sort` parameter indicates that the query results should be listed in reverse numeric order, based on visit count. In other words, the most visited result will be first, and the least visited result last.
- `maxResults=10`: This parameter specifies that a maximum of 10 results should be returned by the query.

If you wanted to change this query to only consider visits that took place today, you could change it to:

```
place:queryType=0&sort=8&maxResults=10&beginTimeRef=1&beginTime=0
```

The new parameters added here are:

- `beginTimeRef=1`: Indicates that the `beginTime` parameter that follows is specified as relative to midnight this morning.
- `beginTime`: Specifies the amount of time, in microseconds, from midnight at which to begin looking for visits. By specifying zero for this value, we indicate that we wish to consider all visits that occurred today.

## Query parameters
Here's a list of the parameters available that you can look for.

| **Parameter**    | **Type**        | **Description**                                                                                                                                                                                                                            |
|------------------|-----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `beginTime`      | `unsigned long` | The time, in microseconds of the earliest result to return.                                                                                                                                                                                |
| `beginTimeRef`   | `unsigned long` | Indicates the type of reference specified in `beginTime`:                                                                                                                                                                                  |
|                  |                 | `0`:     The time is relative to January 1, 1970 GMT. This is the default.                                                                                                                                                                 |
|                  |                 | `1`: The time is relative to this morning at midnight. This is useful for queries relative to "today."                                                                                                                                     |
|                  |                 | `2`: The time is relative to right now.                                                                                                                                                                                                    |
| `endTime`        | `unsigned long` | The time, in microseconds, of the latest result to return.                                                                                                                                                                                 |
| `endTimeRef`     | `unsigned long` | Indicates the type of reference specified in `endTime`. The values are the same as for beginTime.                                                                                                                                          |
| `terms`          | `string`        | The term to query.                                                                                                                                                                                                                         |
| `minVisits`      | `long`          | Filters results based on the minimum number of visits. Specify -1 (the default) to return all results, or any other number to only include results with a visit count higher than the given value.                                         |
| `maxVisits`      | `long`          | Filters results based on the maximum number of visits. Only items that have been visited fewer than this number of times are included in the results. Specify -1 (which is the default) to not filter based on a maximum number of visits. |
| `onlyBookmarked` | `boolean`       | If `true`, only bookmarked items are included in the results.                                                                                                                                                                              |
| `domainIsHost`   | `boolean`       | If `true`, `domain` must be an exact match. Otherwise, anything that ends in `domain` is considered a match.                                                                                                                               |
| `domain`         | `string`        | Query for items matching this host or domain name. See `domainIsHost` for more information.                                                                                                                                                |
| `folder`         | `string`        | The folder to query. This may be one of the following:                                                                                                                                                                                     |
|                  |                 | `PLACES_ROOT`: The Places root folder.                                                                                                                                                                                                     |
|                  |                 | `BOOKMARKS_MENU`: The Bookmarks menu.                                                                                                                                                                                                      |
|                  |                 | `TOOLBAR`: The bookmarks toolbar.                                                                                                                                                                                                          |
|                  |                 | `TAGS`: Tags                                                                                                                                                                                                                               |
|                  |                 | `UNFILED_BOOKMARKS`: Unfiled bookmarks                                                                                                                                                                                                     |
| `!annotation`    | `boolean`       | Indicates whether to include or reject items matching the annotation specified by `annotation`. If `true`, items that don't have the specified annotation are rejected.                                                                    |
| `annotation`     | `string`        | The annotation to match when querying.                                                                                                                                                                                                     |
| `uri`            | `string`        | The URI to match.                                                                                                                                                                                                                          |
| `uriIsPrefix`    | `boolean`       | If `false`, the uri must be an exact match; this is the default. If `true`, any entry that begins with the specified URI is considered a match.                                                                                            |
| `tag`            | `string`        | -                                                                                                                                                                                                                                          |
| `!tas`           | -               | -                                                                                                                                                                                                                                          |

## Query operators
The following attributes allow you to control the results more precisely.

| **Operator**                                                   | **Type**         | **Description**                                                                                                                                                                                                                                      |
|----------------------------------------------------------------|------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `OR`                                                           |                  | This is the OR logical operator.                                                                                                                                                                                                                     |
| `applyOptionsToContainers`                                     |                  |                                                                                                                                                                                                                                                      |
| `excludeItemIfParentHasAnnotation` - Obsolete since Gecko 13.0 | `string`         | Items whose parent has this value as an annotation are excluded from the query results. This parameter is ignored for queries over history. For example, you can exclude livemark entries by specifying "livemark/feedURI" here.                     |
| `excludeItems`                                                 | `boolean`        | If `true`, all URIs and separators are excluded from the bookmark query results, so that only folders and queries are returned. If `false`, all items are returned; this is the default.                                                             |
| `excludeQueries`                                               | `boolean`        | If `true`, queries are excluded from the results; however, simple folder queries like bookmark folder symlinks will still be included. `false`, the default, indicates that queries should be included in the results.                               |
| `excludeReadOnlyFolders`                                       | `boolean`        | If `true`, read-only folders are excluded from the results. This only affects cases in which the actual folder result node would appear in its parent folder. The default is `false`.                                                                |
| `expandQueries`                                                | `boolean`        | If `true`, `place` URIs appear as containers in the results, with the contents filled in from the stored query. This doesn't do anything if `excludeQueries` is `true`. The default is `false`, which causes `place` URIs to appear as normal items. |
| `group`                                                        |                  |                                                                                                                                                                                                                                                      |
| `includeHidden`                                                | `boolean`        | If `true`, items that would normally be hidden in a history query (such as the content of iframes as well as images) are included in the results. This is `false` by default.                                                                        |
| `maxResults`                                                   | `unsigned long`  | The maximum number of results to return. This doesn't work when sorting by title. The result is `0`, which means that all results are returned.                                                                                                      |
| `originalTitle`                                                | `string`         | Retrieves the original page title.                                                                                                                                                                                                                   |
| `queryType`                                                    | `unsigned short` | The type of search to use when querying the database. This attribute is only honored by query nodes. It's ignored for simple folder queries.                                                                                                         |
|                                                                |                  | `0`: History                                                                                                                                                                                                                                         |
|                                                                |                  | `1`: Bookmarks                                                                                                                                                                                                                                       |
|                                                                |                  | `2`:     Both history and bookmarks (**Not yet implemented** -- see [bug 378798](https://bugzilla.mozilla.org/show_bug.cgi?id=378798))                                                                                                               |
| `resolveNullBookmarkTitles`                                    | `boolean`        | If `true`, bookmarks with null titles get their page titles fetched from history if possible. This doesn't apply to bookmarks with empty titles. The default is `false`.                                                                             |
| `showSessions`                                                 | `boolean`        | If `true`, session information is used to group history items. This only makes a difference when sorting by date. The default is `false`.                                                                                                            |
| `sort`                                                         | `unsigned short` | The sort order to use for the results.                                                                                                                                                                                                               |
|                                                                |                  | `0`:     Natural bookmark order                                                                                                                                                                                                                      |
|                                                                |                  | `1`:      Sort by title, A-Z                                                                                                                                                                                                                         |
|                                                                |                  | `2`:       Sort by title, Z-A                                                                                                                                                                                                                        |
|                                                                |                  | `3`:      Sort by visit date, most recent last                                                                                                                                                                                                       |
|                                                                |                  | `4`:     Sort by visit date, most recent first                                                                                                                                                                                                       |
|                                                                |                  | `5`:       Sort by uri, A-Z                                                                                                                                                                                                                          |
|                                                                |                  | `6`:      Sort by uri, Z-A                                                                                                                                                                                                                           |
|                                                                |                  | `7`:      Sort by visit count, ascending                                                                                                                                                                                                             |
|                                                                |                  | `8`:     Sort by visit count, descending                                                                                                                                                                                                             |
|                                                                |                  | `9`:       Sort by keyword, A-Z                                                                                                                                                                                                                      |
|                                                                |                  | `10`:       Sort by keyword, Z-A                                                                                                                                                                                                                     |
|                                                                |                  | `11`:      Sort by date added, most recent last                                                                                                                                                                                                      |
|                                                                |                  | `12`:       Sort by date added, most recent first                                                                                                                                                                                                    |
|                                                                |                  | `13`:       Sort by last modified date, most recent last                                                                                                                                                                                             |
|                                                                |                  | `14`:      Sort by last modified date, most recent first                                                                                                                                                                                             |
|                                                                |                  | `17`:   Sort by tags, ascending                                                                                                                                                                                                                      |
|                                                                |                  | `18`:  Sort by tags, descending                                                                                                                                                                                                                      |
|                                                                |                  | `19`:      Sort by annotation, ascending                                                                                                                                                                                                             |
|                                                                |                  | `20`:     Sort by annotation, descending                                                                                                                                                                                                             |
| `sortingAnnotation`                                            | `string`         | The annotation to use when sorting by annotation.                                                                                                                                                                                                    |
| `type`                                                         | `unsigned short` | The type of results to return.                                                                                                                                                                                                                       |
|                                                                |                  | `0`:     Results as URI ("URI" results, one for each URI visited in the range).                                                                                                                                                                      |
|                                                                |                  | `1`:     Results as visit ("visit" results, with one for each time a page was visited this will often give you multiple results for one URI).                                                                                                        |
|                                                                |                  | `2`:     Results as full visits (like "visit", but returns all attributes for each result)                                                                                                                                                           |
|                                                                |                  | `3`:     Results as date query (returns results for given date range)                                                                                                                                                                                |
|                                                                |                  | `4`:     Results as site query (returns last visit for each url in the given host)                                                                                                                                                                   |
|                                                                |                  | `5`:     Results as date+site query (returns list of hosts visited in the given period)                                                                                                                                                              |
|                                                                |                  | `6`:     Results as tag query (returns list of bookmarks with the given tag)                                                                                                                                                                         |
|                                                                |                  | `7`:     Results as tag container (returns bookmarks with given tag; for same uri uses last modified. `folder=tag_folder_id` must be present in the query                                                                                            |
