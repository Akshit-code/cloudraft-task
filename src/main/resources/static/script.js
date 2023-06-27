$(document).ready(function() {
    $("#setForm").submit(function(event) {
        event.preventDefault();
        var key = $("#setKey").val();
        var value = $("#setValue").val();
        var requestData = {
            key: key,
            value: value
        };
        $.post({
            url: "/set",
            data: JSON.stringify(requestData),
            dataType: "json",
            contentType: "application/json",
            success: function(data) {
                $("#response").text("Set successful");
            }
        });
    });
 
    $("#getForm").submit(function(event) {
        event.preventDefault();
        var key = $("#getKey").val();
        $.get("/get/" + key, function(data) {
            $("#response").text("Value: " + data);
        });
    });
 
    $("#searchForm").submit(function(event) {
        event.preventDefault();
        var prefix = $("#searchPrefix").val();
        var suffix = $("#searchSuffix").val();
        var url = "/search";
        if (prefix) {
            url += "?prefix=" + prefix;
        }
        if (suffix) {
            url += (prefix ? "&" : "?") + "suffix=" + suffix;
        }
        $.get(url, function(data) {
            $("#response").text("Keys: " + data);
        });
    });
 });
 