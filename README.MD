This is a very simple app to parse a feed and display a limited amount of that data in a way that could be embedded in an email. 


** References **

```
    This loops though all in feed   
    <% @events.each do |event| %>
          
              <%= event['Title'] %>
            
              <%= DateTime.parse(event['StartDate']).strftime('%A %b %e %I:%M:%S %p')  %>
            
              <%=  event['Description'] %>
            <a href="https://www.winterparkresort.com<%=  event['EventLink'] %>">Learn More</a><img src="https://www.winterparkresort.com<%=  event['ImageLink'] %>" width="300"> </td>
         
          <% end %>
  
```

Event and Trust You `resort` key:
  * Winter Park = 0 
  * Tremblant = 1 
  * Steamboat = 2
  * Snowshoe = 3 
  * Stratton = 4
  * Blue = 5 


Lodging `resort` key:
  * Blue Mountain = 0 
  * Stratton Mountain = 1 
  * Steamboat Resort = 2
  * "Winter Park Resort = 3 
  * Snowshoe Resort = 4
  * Tremblant = 5 

