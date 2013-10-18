function feed(params, context, done) {
    Kii.initializeWithSite(context.getAppID(), context.getAppKey(), KiiSite.US);
    
    // get the feed
    var bucket = Kii.bucketWithName("feed");

    // Build "all" query
    var query = KiiQuery.queryWithClause();
    query.sortByDesc("_created");

    var totalResults = [];

    // Define the callbacks
    var queryCallbacks = {
        success: function(queryPerformed, resultSet, nextQuery) {
        
            // do something with the results
            for(var i=0; i<resultSet.length; i++) {
                // do something with the object
                var obj = resultSet[i];
                
                var newObj = new Object();
                newObj.uri = obj.objectURI();
                newObj.message = obj.get("message");
                newObj.username = obj.get("username");
                newObj.created = obj.getCreated();
                
                totalResults.push(newObj);
            }
            
            // now get our twitter hashtag results
            done(totalResults);
        },
        
        failure: function(queryPerformed, anErrorString) {
            // do something with the error response
            done(anErrorString);
        }
    }

    // Execute the query
    bucket.executeQuery(query, queryCallbacks);

}
