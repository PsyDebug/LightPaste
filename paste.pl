#!/usr/bin/env perl
use Mojolicious::Lite;
use Encode;

my $storage="storage/";
push @{app->static->paths} => 'stat/';

get '/' => sub {
  my $c = shift;
  $c->render(template => 'home');
};
post '/add' => sub	{
	my $c = shift;
	my $url=$c->req->content->headers->referrer;
	my $text=$c->param('text');
	if($text){
		my @cs = ("a".."z","A".."Z",0..9);
	    my $token = join("",@cs[map { rand @cs } (1..6) ]);		
		open(GG,">$storage/$token");
		print GG "$text\n";
		close(GG);
		$c->render(msg => "$url$token");
	}
	else {$c->render(template => 'not_found');}
};
	
get '/:file' => sub {
  my $c = shift;
  my $fileContent;
  my $pathf=$c->param('file');
  if(open(my $F,"$storage/$pathf")) {
  binmode($F);
{
 local $/;
 $fileContent = <$F>;
}
close($F);
  $fileContent=decode('utf8',$fileContent);
  $c->render(template => 'index', msg => $fileContent);
}
else {$c->render(template => 'not_found');}

};

app->start;
__DATA__

@@ home.html.ep
<!DOCTYPE html>
<html>
  <head>
  <link href="/main.css" rel="stylesheet" type="text/css">
  <%= javascript "/jquery.min.js" %>
  
  <title>PasteLight</title>
  </head>  
  <body bgcolor="#333">
  <div class="allp" align="center">
  <h2 style="color:white;">Minimalism pastebin</h2>
  <p ><textarea class="alltext" form="form" rows="30" cols="100" name="text" style="resize: none;" required></textarea></p>
  <a class="semi-transparent-button"  href="#">Create</a>  </div>
   <%= javascript begin %>
  
$(".semi-transparent-button").on("click",function(){
   var val = $(".alltext").serialize();
   $.ajax({
                type: "POST",
                url: "/add",
                data: val,
                success: function(html) {
                        $(".allp").empty();
                        $(".allp").append(html+"<a style='color:red;' href='/'>NEW</a>");
                }
       });
});
   
   <% end %>

  
  </body>
</html>

@@ index.html.ep
% layout 'default';
% title 'LightPaste';
<p class="ssp"><%= $msg %></p>


@@ layouts/default.html.ep
<!DOCTYPE html>
<html>

  <head>
  <title><%= title %></title>
  <link href="/agate.css" rel="stylesheet" type="text/css">
   <%= javascript "/highlight.pack.js" %>
   <script>hljs.initHighlightingOnLoad();</script>
  <style>
.allp {
margin: 20px;
}
.ssp{
	border: 1px dashed #666; 
    padding: 7px; 
    margin: 0 0 1em;
    white-space: pre-wrap;
    }
</style>

  </head>  
  <body bgcolor="#333">
  <a style="color:white;" href='/'>HOME</a>
  <div class="allp">
  <pre><code><%= content %></code></pre>
  </div></body>
</html>

@@ add.html.ep
<h1 ><a style="color:white;" href='<%= $msg %>'><%= $msg %></a></h1>

@@ not_found.html.ep
{"status":"false"}
