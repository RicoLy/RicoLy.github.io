---
layout: post
title: golang protobuf 教程
category: Golang,Protobuf
tags: Golang,Protobuf
description: Golang Protobuf RPC
---


<article class="devsite-article-inner">
  
          
  


<div class="devsite-rating-container
            "><div class="devsite-rating-stars"><div class="devsite-rating-star devsite-rating-star-outline gc-analytics-event material-icons" data-rating-val="1" data-category="Site-Wide Custom Events" data-label="Star Rating 1" track-metadata-score="1" track-type="feedback" track-name="rating" track-metadata-position="header" role="button" aria-label="Site content star ratings, rating 1 out of 5"></div><div class="devsite-rating-star devsite-rating-star-outline gc-analytics-event material-icons" data-rating-val="2" data-category="Site-Wide Custom Events" data-label="Star Rating 2" track-metadata-score="2" track-type="feedback" track-name="rating" track-metadata-position="header" role="button" aria-label="Site content star ratings, rating 2 out of 5"></div><div class="devsite-rating-star devsite-rating-star-outline gc-analytics-event material-icons" data-rating-val="3" data-category="Site-Wide Custom Events" data-label="Star Rating 3" track-metadata-score="3" track-type="feedback" track-name="rating" track-metadata-position="header" role="button" aria-label="Site content star ratings, rating 3 out of 5"></div><div class="devsite-rating-star devsite-rating-star-outline gc-analytics-event material-icons" data-rating-val="4" data-category="Site-Wide Custom Events" data-label="Star Rating 4" track-metadata-score="4" track-type="feedback" track-name="rating" track-metadata-position="header" role="button" aria-label="Site content star ratings, rating 4 out of 5"></div><div class="devsite-rating-star devsite-rating-star-outline gc-analytics-event material-icons" data-rating-val="5" data-category="Site-Wide Custom Events" data-label="Star Rating 5" track-metadata-score="5" track-type="feedback" track-name="rating" track-metadata-position="header" role="button" aria-label="Site content star ratings, rating 5 out of 5"></div></div><div class="devsite-rating-description"></div><div class="devsite-rating-internal"><span class="devsite-rating-stats"></span></div></div><script>
  $(document).ready(function() {
    devsite.ratings.init(
      document.querySelectorAll('#devsite-feedback-project'), false
      
    );
  });
</script>


  
  <nav class="devsite-breadcrumb-nav devsite-nav">
    


<ul class="devsite-breadcrumb-list">
  
  <li class="devsite-breadcrumb-item">
    
    
    <a href="https://developers.google.com/products/" class="devsite-breadcrumb-link gc-analytics-event" data-category="Site-Wide Custom Events" data-label="Breadcrumbs" data-value="1">
    
    
      Products
    
    
    </a>
    
  </li>
  
  <li class="devsite-breadcrumb-item">
    
    
    <div class="devsite-breadcrumb-guillemet material-icons"></div>
    
    
    <a href="https://developers.google.com/protocol-buffers/" class="devsite-breadcrumb-link gc-analytics-event" data-category="Site-Wide Custom Events" data-label="Breadcrumbs" data-value="2">
    
    
      Protocol Buffers
    
    
    </a>
    
  </li>
  
  <li class="devsite-breadcrumb-item">
    
    
    <div class="devsite-breadcrumb-guillemet material-icons"></div>
    
    
    <a href="https://developers.google.com/protocol-buffers/docs/overview" class="devsite-breadcrumb-link gc-analytics-event" data-category="Site-Wide Custom Events" data-label="Breadcrumbs" data-value="3">
    
    
      Guides
    
    
    </a>
    
  </li>
  
</ul>

  </nav>
  
  
  <h1 itemprop="name" class="devsite-page-title">
    Protocol Buffer Basics: Go
  </h1>
  
  
  <nav class="devsite-page-nav-embedded devsite-nav"><ul class="devsite-page-nav-list"><li class="devsite-nav-item devsite-nav-item-heading"><a href="#top_of_page" class="devsite-nav-title"><span>Contents</span></a><button type="button" class="devsite-nav-show-all button-transparent material-icons" data-tooltip-align="b,c" data-tooltip="Expand/collapse contents" aria-label="Expand/collapse contents" data-title="Expand/collapse contents"></button></li><li class="devsite-nav-item"><a href="#why-use-protocol-buffers" class="devsite-nav-title"><span>Why use protocol buffers?</span></a></li><li class="devsite-nav-item"><a href="#where-to-find-the-example-code" class="devsite-nav-title"><span>Where to find the example code</span></a></li><li class="devsite-nav-item"><a href="#defining-your-protocol-format" class="devsite-nav-title"><span>Defining your protocol format</span></a></li><li class="devsite-nav-item"><a href="#compiling-your-protocol-buffers" class="devsite-nav-title"><span>Compiling your protocol buffers</span></a></li><li class="devsite-nav-item"><a href="#the-protocol-buffer-api" class="devsite-nav-title devsite-nav-item-hidden"><span>The Protocol Buffer API</span></a></li><li class="devsite-nav-item"><a href="#writing-a-message" class="devsite-nav-title devsite-nav-item-hidden"><span>Writing a Message</span></a></li><li class="devsite-nav-item"><a href="#reading-a-message" class="devsite-nav-title devsite-nav-item-hidden"><span>Reading a Message</span></a></li><li class="devsite-nav-item"><a href="#extending-a-protocol-buffer" class="devsite-nav-title devsite-nav-item-hidden"><span>Extending a Protocol Buffer</span></a></li><li class="devsite-nav-item"><button type="button" class="button-flat devsite-nav-more-items material-icons" aria-hidden="true" data-tooltip-align="b,c" data-tooltip="Expand/collapse contents" aria-label="Expand/collapse contents" data-title="Expand/collapse contents"></button></li></ul></nav>
  
  <div class="devsite-article-body clearfix
            " itemprop="articleBody">
    














 
 
 
 
 











<p>This tutorial provides a basic Go programmer's introduction to working with protocol buffers, using the <a href="https://developers.google.com/protocol-buffers/docs/proto3">proto3</a> version of the protocol buffers language.  By walking through creating a simple example application, it shows you how to
</p><ul>
  <li>Define message formats in a <code>.proto</code> file.
  </li><li>Use the protocol buffer compiler.
  </li><li>Use the Go protocol buffer API to write and read messages.
</li></ul>
<p>This isn't a comprehensive guide to using protocol buffers in Go.  For more detailed reference information, see the <a href="https://developers.google.com/protocol-buffers/docs/proto3">Protocol Buffer Language Guide</a>, the <a href="https://godoc.org/github.com/golang/protobuf/proto">Go API Reference</a>, the <a href="https://developers.google.com/protocol-buffers/docs/reference/go-generated">Go Generated Code Guide</a>, and the <a href="https://developers.google.com/protocol-buffers/docs/encoding">Encoding Reference</a>.

<!--=========================================================================-->
</p><h2 id="why-use-protocol-buffers"><a href="#top_of_page" class="devsite-back-to-top-link material-icons" data-tooltip-align="b,c" data-tooltip="Back to top" aria-label="Back to top" data-title="Back to top"></a>Why use protocol buffers?</h2>
<p>The example we're going to use is a very simple "address book" application that can read and write people's contact details to and from a file.  Each person in the address book has a name, an ID, an email address, and a contact phone number.
</p><p>How do you serialize and retrieve structured data like this? There are a few ways to solve this problem:
</p><ul>
  
  
    <li>Use <a href="//golang.org/pkg/encoding/gob/">gobs</a> to serialize Go data structures.  This is a good solution in a Go-specific environment, but it doesn't work well if you need to share data with applications written for other platforms.
  
  
  
  
  </li><li>You can invent an ad-hoc way to encode the data items into a single string – such as encoding 4 ints as "12:3:-23:67". This is a simple and flexible approach, although it does require writing one-off encoding and parsing code, and the parsing imposes a small run-time cost. This works best for encoding very simple data.
  </li><li>Serialize the data to XML. This approach can be very attractive since XML is (sort of) human readable and there are binding libraries for lots of languages. This can be a good choice if you want to share data with other applications/projects. However, XML is notoriously space intensive, and encoding/decoding it can impose a huge performance penalty on applications.  Also, navigating an XML DOM tree is considerably more complicated than navigating simple fields in a class normally would be.
</li></ul>
<p>Protocol buffers are the flexible, efficient, automated solution to solve exactly this problem. With protocol buffers, you write a <code>.proto</code> description of the data structure you wish to store. From that, the protocol buffer compiler creates a class that implements automatic encoding and parsing of the protocol buffer data with an efficient binary format. The generated class provides getters and setters for the fields that make up a protocol buffer and takes care of the details of reading and writing the protocol buffer as a unit. Importantly, the protocol buffer format supports the idea of extending the format over time in such a way that the code can still read data encoded with the old format.</p>

<!--=========================================================================-->
<h2 id="where-to-find-the-example-code"><a href="#top_of_page" class="devsite-back-to-top-link material-icons" data-tooltip-align="b,c" data-tooltip="Back to top" aria-label="Back to top" data-title="Back to top"></a>Where to find the example code</h2>
<p>Our example is a set of command-line
applications for managing an address book
data file, encoded using protocol buffers.

  The command <code>add_person_go</code> adds a new entry to the data
  file. The command <code>list_people_go</code> parses the data file
  and prints the data to the console.



</p><p>You can find the complete example in the
<a href="https://github.com/protocolbuffers/protobuf/tree/master/examples">examples directory</a>

of the GitHub repository.

<!--=========================================================================-->
</p><h2 id="defining-your-protocol-format"><a href="#top_of_page" class="devsite-back-to-top-link material-icons" data-tooltip-align="b,c" data-tooltip="Back to top" aria-label="Back to top" data-title="Back to top"></a>Defining your protocol format</h2>
<p>To create your address book application, you'll need to start with a
<code>.proto</code> file. The definitions in a <code>.proto</code> file are
simple: you add a <em>message</em> for each data structure you want to
serialize, then specify a name and a type for each field in the message.  In
our example, the <code>.proto</code> file that defines the messages is
<a href="https://github.com/protocolbuffers/protobuf/blob/master/examples/addressbook.proto"><code>addressbook.proto</code></a>.

</p><p>The <code>.proto</code> file starts with a package declaration, which helps
to prevent naming conflicts between different projects.

  </p><pre class="prettyprint"><div class="devsite-code-button-wrapper"><div class="devsite-code-button gc-analytics-event material-icons devsite-dark-code-button" data-category="Site-Wide Custom Events" data-label="Dark Code Toggle" track-type="exampleCode" track-name="darkCodeToggle" data-tooltip-align="b,c" data-tooltip="Dark code theme" aria-label="Dark code theme" data-title="Dark code theme"></div><div class="devsite-code-button gc-analytics-event material-icons devsite-click-to-copy-button" data-category="Site-Wide Custom Events" data-label="Click To Copy" track-type="exampleCode" track-name="clickToCopy" data-tooltip-align="b,c" data-tooltip="Click to copy" aria-label="Click to copy" data-title="Click to copy"></div></div><span class="pln">syntax </span><span class="pun">=</span><span class="pln"> </span><span class="str">"proto3"</span><span class="pun">;</span><span class="pln"><br></span><span class="kwd">package</span><span class="pln"> tutorial</span><span class="pun">;</span><span class="pln"><br><br></span><span class="kwd">import</span><span class="pln"> </span><span class="str">"google/protobuf/timestamp.proto"</span><span class="pun">;</span></pre>

<p>

  In Go, the <code>package</code> name is used as the Go package, unless you
  have specified a <code>go_package</code>.  Even if you do provide a
  <code>go_package</code>, you should still define a normal
  <code>package</code> as well to avoid name collisions in the Protocol Buffers
  name space as well as in non-Go languages.





</p><p>Next, you have your message definitions.  A message is just an aggregate
containing a set of typed fields.  Many standard simple data types are
available as field types, including <code>bool</code>, <code>int32</code>,
<code>float</code>, <code>double</code>, and <code>string</code>. You can also
add further structure to your messages by using other message types as field
types.

  </p><pre class="prettyprint"><div class="devsite-code-button-wrapper"><div class="devsite-code-button gc-analytics-event material-icons devsite-dark-code-button" data-category="Site-Wide Custom Events" data-label="Dark Code Toggle" track-type="exampleCode" track-name="darkCodeToggle" data-tooltip-align="b,c" data-tooltip="Dark code theme" aria-label="Dark code theme" data-title="Dark code theme"></div><div class="devsite-code-button gc-analytics-event material-icons devsite-click-to-copy-button" data-category="Site-Wide Custom Events" data-label="Click To Copy" track-type="exampleCode" track-name="clickToCopy" data-tooltip-align="b,c" data-tooltip="Click to copy" aria-label="Click to copy" data-title="Click to copy"></div></div><span class="pln">message </span><span class="typ">Person</span><span class="pln"> </span><span class="pun">{</span><span class="pln"><br>&nbsp; </span><span class="kwd">string</span><span class="pln"> name </span><span class="pun">=</span><span class="pln"> </span><span class="lit">1</span><span class="pun">;</span><span class="pln"><br>&nbsp; int32 id </span><span class="pun">=</span><span class="pln"> </span><span class="lit">2</span><span class="pun">;</span><span class="pln"> &nbsp;</span><span class="com">// Unique ID number for this person.</span><span class="pln"><br>&nbsp; </span><span class="kwd">string</span><span class="pln"> email </span><span class="pun">=</span><span class="pln"> </span><span class="lit">3</span><span class="pun">;</span><span class="pln"><br><br>&nbsp; </span><span class="kwd">enum</span><span class="pln"> </span><span class="typ">PhoneType</span><span class="pln"> </span><span class="pun">{</span><span class="pln"><br>&nbsp; &nbsp; MOBILE </span><span class="pun">=</span><span class="pln"> </span><span class="lit">0</span><span class="pun">;</span><span class="pln"><br>&nbsp; &nbsp; HOME </span><span class="pun">=</span><span class="pln"> </span><span class="lit">1</span><span class="pun">;</span><span class="pln"><br>&nbsp; &nbsp; WORK </span><span class="pun">=</span><span class="pln"> </span><span class="lit">2</span><span class="pun">;</span><span class="pln"><br>&nbsp; </span><span class="pun">}</span><span class="pln"><br><br>&nbsp; message </span><span class="typ">PhoneNumber</span><span class="pln"> </span><span class="pun">{</span><span class="pln"><br>&nbsp; &nbsp; </span><span class="kwd">string</span><span class="pln"> number </span><span class="pun">=</span><span class="pln"> </span><span class="lit">1</span><span class="pun">;</span><span class="pln"><br>&nbsp; &nbsp; </span><span class="typ">PhoneType</span><span class="pln"> type </span><span class="pun">=</span><span class="pln"> </span><span class="lit">2</span><span class="pun">;</span><span class="pln"><br>&nbsp; </span><span class="pun">}</span><span class="pln"><br><br>&nbsp; repeated </span><span class="typ">PhoneNumber</span><span class="pln"> phones </span><span class="pun">=</span><span class="pln"> </span><span class="lit">4</span><span class="pun">;</span><span class="pln"><br><br>&nbsp; google</span><span class="pun">.</span><span class="pln">protobuf</span><span class="pun">.</span><span class="typ">Timestamp</span><span class="pln"> last_updated </span><span class="pun">=</span><span class="pln"> </span><span class="lit">5</span><span class="pun">;</span><span class="pln"><br></span><span class="pun">}</span><span class="pln"><br><br></span><span class="com">// Our address book file is just one of these.</span><span class="pln"><br>message </span><span class="typ">AddressBook</span><span class="pln"> </span><span class="pun">{</span><span class="pln"><br>&nbsp; repeated </span><span class="typ">Person</span><span class="pln"> people </span><span class="pun">=</span><span class="pln"> </span><span class="lit">1</span><span class="pun">;</span><span class="pln"><br></span><span class="pun">}</span></pre>

<p>In the above example, the <code>Person</code> message contains
<code>PhoneNumber</code> messages, while the <code>AddressBook</code> message
contains <code>Person</code> messages.  You can even define message types
nested inside other messages – as you can see, the
<code>PhoneNumber</code> type is defined inside <code>Person</code>.  You can
also define <code>enum</code> types if you want one of your fields to have one
of a predefined list of values – here you want to specify that a phone
number can be one of <code>MOBILE</code>, <code>HOME</code>, or
<code>WORK</code>.

</p><p>The " = 1", " = 2" markers on each element identify the unique "tag" that field uses in the binary encoding. Tag numbers 1-15 require one less byte to encode than higher numbers, so as an optimization you can decide to use those tags for the commonly used or repeated elements, leaving tags 16 and higher for less-commonly used optional elements.  Each element in a repeated field requires re-encoding the tag number, so repeated fields are particularly good candidates for this optimization.

</p><p>If a field value isn't set, a
<a href="https://developers.google.com/protocol-buffers/docs/proto3#default">default value</a> is used: zero
for numeric types, the empty string for strings, false for bools.  For embedded
messages, the default value is always the "default instance" or "prototype" of
the message, which has none of its fields set.  Calling the accessor to get the
value of a field which has not been explicitly set always returns that field's
default value.

</p><p>If a field is <code>repeated</code>, the field may be repeated any number of times (including zero). The order of the repeated values will be preserved in the protocol buffer. Think of repeated fields as dynamically sized arrays.

</p><p>You'll find a complete guide to writing <code>.proto</code> files – including all the possible field types –  in the <a href="https://developers.google.com/protocol-buffers/docs/proto3">Protocol Buffer Language Guide</a>. Don't go looking for facilities similar to class inheritance, though – protocol buffers don't do that.

<!--=========================================================================-->
</p><h2 id="compiling-your-protocol-buffers"><a href="#top_of_page" class="devsite-back-to-top-link material-icons" data-tooltip-align="b,c" data-tooltip="Back to top" aria-label="Back to top" data-title="Back to top"></a>Compiling your protocol buffers</h2>
<p>Now that you have a <code>.proto</code>, the next thing you need to do is generate the classes you'll need to read and write <code>AddressBook</code> (and hence <code>Person</code> and <code>PhoneNumber</code>) messages.  To do this, you need to run the protocol buffer compiler <code>protoc</code> on your <code>.proto</code>:
</p><ol>
  <li>If you haven't installed the compiler, <a href="https://developers.google.com/protocol-buffers/docs/downloads.html">download the package</a> and follow the instructions in the README.

  </li><li>Run the following command to install the Go protocol buffers plugin:
    <pre class="prettyprint lang-shell"><div class="devsite-code-button-wrapper"><div class="devsite-code-button gc-analytics-event material-icons devsite-dark-code-button" data-category="Site-Wide Custom Events" data-label="Dark Code Toggle" track-type="exampleCode" track-name="darkCodeToggle" data-tooltip-align="b,c" data-tooltip="Dark code theme" aria-label="Dark code theme" data-title="Dark code theme"></div><div class="devsite-code-button gc-analytics-event material-icons devsite-click-to-copy-button" data-category="Site-Wide Custom Events" data-label="Click To Copy" track-type="exampleCode" track-name="clickToCopy" data-tooltip-align="b,c" data-tooltip="Click to copy" aria-label="Click to copy" data-title="Click to copy"></div></div><span class="pln">go </span><span class="kwd">get</span><span class="pln"> </span><span class="pun">-</span><span class="pln">u github</span><span class="pun">.</span><span class="pln">com</span><span class="pun">/</span><span class="pln">golang</span><span class="pun">/</span><span class="pln">protobuf</span><span class="pun">/</span><span class="pln">protoc</span><span class="pun">-</span><span class="pln">gen</span><span class="pun">-</span><span class="pln">go</span></pre>
    The compiler plugin <code>protoc-gen-go</code> will be installed in
    <code>$GOBIN</code>, defaulting to <code>$GOPATH/bin</code>.  It must be in
    your <code>$PATH</code> for the protocol compiler <code>protoc</code> to
    find it.

  </li><li>Now run the compiler, specifying the source directory (where your application's source code lives – the current directory is used if you don't provide a value), the destination directory (where you want the generated code to go; often the same as <code>$SRC_DIR</code>), and the path to your <code>.proto</code>.  In this case, you...:
<pre><div class="devsite-code-button-wrapper"><div class="devsite-code-button gc-analytics-event material-icons devsite-dark-code-button" data-category="Site-Wide Custom Events" data-label="Dark Code Toggle" track-type="exampleCode" track-name="darkCodeToggle" data-tooltip-align="b,c" data-tooltip="Dark code theme" aria-label="Dark code theme" data-title="Dark code theme"></div></div>protoc -I=$SRC_DIR --go_out=$DST_DIR $SRC_DIR/addressbook.proto</pre>
Because you want Go classes, you use the <code>--go_out</code> option – similar options are provided for other supported languages.
</li></ol>


  <p>This generates <code>addressbook.pb.go</code> in your specified destination directory.









</p><h2 id="the-protocol-buffer-api"><a href="#top_of_page" class="devsite-back-to-top-link material-icons" data-tooltip-align="b,c" data-tooltip="Back to top" aria-label="Back to top" data-title="Back to top"></a>The Protocol Buffer API</h2>
<p>Generating <code>addressbook.pb.go</code> gives you the following useful
types:
  </p><ul>
    <li>An <code>AddressBook</code> structure with a <code>People</code> field.
    </li><li>A <code>Person</code> structure with fields for <code>Name</code>,
      <code>Id</code>, <code>Email</code> and <code>Phones</code>.
    </li><li>A <code>Person_PhoneNumber</code> structure, with fields for
      <code>Number</code> and <code>Type</code>.
    </li><li>The type <code>Person_PhoneType</code> and a value defined for each
      value in the <code>Person.PhoneType</code> enum.
  </li></ul>

<p>You can read more about the details of exactly what's generated in the
<a href="https://developers.google.com/protocol-buffers/docs/reference/go-generated">Go Generated Code guide</a>, but for the most
part you can treat these as perfectly ordinary Go types.

</p><p>Here's an example from the
<a href="https://github.com/protocolbuffers/protobuf/blob/master/examples/list_people_test.go"><code>list_people</code> command's unit tests</a>
of how you might create an instance of Person:</p>

  <pre class="prettyprint lang-go"><div class="devsite-code-button-wrapper"><div class="devsite-code-button gc-analytics-event material-icons devsite-dark-code-button" data-category="Site-Wide Custom Events" data-label="Dark Code Toggle" track-type="exampleCode" track-name="darkCodeToggle" data-tooltip-align="b,c" data-tooltip="Dark code theme" aria-label="Dark code theme" data-title="Dark code theme"></div><div class="devsite-code-button gc-analytics-event material-icons devsite-click-to-copy-button" data-category="Site-Wide Custom Events" data-label="Click To Copy" track-type="exampleCode" track-name="clickToCopy" data-tooltip-align="b,c" data-tooltip="Click to copy" aria-label="Click to copy" data-title="Click to copy"></div></div><span class="pln">p := pb.Person{<br>&nbsp; &nbsp; &nbsp; &nbsp; Id: &nbsp; &nbsp;1234,<br>&nbsp; &nbsp; &nbsp; &nbsp; Name: &nbsp;"John Doe",<br>&nbsp; &nbsp; &nbsp; &nbsp; Email: "jdoe@example.com",<br>&nbsp; &nbsp; &nbsp; &nbsp; Phones: []*pb.Person_PhoneNumber{<br>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; {Number: "555-4321", Type: pb.Person_HOME},<br>&nbsp; &nbsp; &nbsp; &nbsp; },<br>}</span></pre>

<h2 id="writing-a-message"><a href="#top_of_page" class="devsite-back-to-top-link material-icons" data-tooltip-align="b,c" data-tooltip="Back to top" aria-label="Back to top" data-title="Back to top"></a>Writing a Message</h2>

<p>The whole purpose of using protocol buffers is to serialize your data so
that it can be parsed elsewhere.  In Go, you use the <code>proto</code>
library's
<a href="https://godoc.org/github.com/golang/protobuf/proto#Marshal">Marshal</a>
function to serialize your protocol buffer data.  A pointer to a protocol
buffer message's <code>struct</code> implements the <code>proto.Message</code>
interface.  Calling <code>proto.Marshal</code> returns the protocol buffer,
encoded in its wire format.  For example, we use this function in the
<a href="https://github.com/protocolbuffers/protobuf/blob/master/examples/add_person.go"><code>add_person</code> command</a>:

  </p><pre class="prettyprint lang-go"><div class="devsite-code-button-wrapper"><div class="devsite-code-button gc-analytics-event material-icons devsite-dark-code-button" data-category="Site-Wide Custom Events" data-label="Dark Code Toggle" track-type="exampleCode" track-name="darkCodeToggle" data-tooltip-align="b,c" data-tooltip="Dark code theme" aria-label="Dark code theme" data-title="Dark code theme"></div><div class="devsite-code-button gc-analytics-event material-icons devsite-click-to-copy-button" data-category="Site-Wide Custom Events" data-label="Click To Copy" track-type="exampleCode" track-name="clickToCopy" data-tooltip-align="b,c" data-tooltip="Click to copy" aria-label="Click to copy" data-title="Click to copy"></div></div><span class="pln">book := &amp;pb.AddressBook{}<br></span><span class="com">// ...</span><span class="pln"><br><br></span><span class="com">// Write the new address book back to disk.</span><span class="pln"><br>out, err := proto.Marshal(book)<br>if err != nil {<br>&nbsp; &nbsp; &nbsp; &nbsp; log.Fatalln("Failed to encode address book:", err)<br>}<br>if err := ioutil.WriteFile(fname, out, 0644); err != nil {<br>&nbsp; &nbsp; &nbsp; &nbsp; log.Fatalln("Failed to write address book:", err)<br>}</span></pre>

<h2 id="reading-a-message"><a href="#top_of_page" class="devsite-back-to-top-link material-icons" data-tooltip-align="b,c" data-tooltip="Back to top" aria-label="Back to top" data-title="Back to top"></a>Reading a Message</h2>

<p>To parse an encoded message, you use the <code>proto</code> library's
<a href="https://godoc.org/github.com/golang/protobuf/proto#Unmarshal">Unmarshal</a>
function.  Calling this parses the data in <code>buf</code> as a protocol
buffer and places the result in <code>pb</code>.  So to parse the file in the
<a href="https://github.com/protocolbuffers/protobuf/blob/master/examples/list_people.go"><code>list_people</code> command</a>,
we use:

  </p><pre class="prettyprint lang-go"><div class="devsite-code-button-wrapper"><div class="devsite-code-button gc-analytics-event material-icons devsite-dark-code-button" data-category="Site-Wide Custom Events" data-label="Dark Code Toggle" track-type="exampleCode" track-name="darkCodeToggle" data-tooltip-align="b,c" data-tooltip="Dark code theme" aria-label="Dark code theme" data-title="Dark code theme"></div><div class="devsite-code-button gc-analytics-event material-icons devsite-click-to-copy-button" data-category="Site-Wide Custom Events" data-label="Click To Copy" track-type="exampleCode" track-name="clickToCopy" data-tooltip-align="b,c" data-tooltip="Click to copy" aria-label="Click to copy" data-title="Click to copy"></div></div><span class="com">// Read the existing address book.</span><span class="pln"><br>in, err := ioutil.ReadFile(fname)<br>if err != nil {<br>&nbsp; &nbsp; &nbsp; &nbsp; log.Fatalln("Error reading file:", err)<br>}<br>book := &amp;pb.AddressBook{}<br>if err := proto.Unmarshal(in, book); err != nil {<br>&nbsp; &nbsp; &nbsp; &nbsp; log.Fatalln("Failed to parse address book:", err)<br>}</span></pre>


<h2 id="extending-a-protocol-buffer"><a href="#top_of_page" class="devsite-back-to-top-link material-icons" data-tooltip-align="b,c" data-tooltip="Back to top" aria-label="Back to top" data-title="Back to top"></a>Extending a Protocol Buffer</h2>

<p>Sooner or later after you release the code that uses your protocol buffer,
you will undoubtedly want to "improve" the protocol buffer's definition. If you
want your new buffers to be backwards-compatible, and your old buffers to be
forward-compatible – and you almost certainly do want this – then
there are some rules you need to follow.  In the new version of the
protocol buffer:

</p><ul>
  <li>you <em>must not</em> change the tag numbers of any existing fields.
  </li><li>you <em>may</em> delete fields.
  </li><li>you <em>may</em> add new fields but you must use fresh tag numbers (i.e.
    tag numbers that were never used in this protocol buffer, not even by
    deleted fields).
</li></ul>

<p>(There are
<a href="https://developers.google.com/protocol-buffers/docs/proto3.html#updating">some exceptions</a> to
these rules, but they are rarely used.)

</p><p>If you follow these rules, old code will happily read new messages and
simply ignore any new fields.  To the old code, singular fields that were
deleted will simply have their default value, and deleted repeated fields will
be empty.  New code will also transparently read old messages.

</p><p>However, keep in mind that new fields will not be present in old messages,
so you will need to do something reasonable with the default value.  A
type-specific
<a href="https://developers.google.com/protocol-buffers/docs/proto3#default">default value</a>
is used: for strings, the default value is the empty string. For booleans, the
default value is false.  For numeric types, the default value is zero.




  </p></div>
  

  
        
  







        
<div class="devsite-content-footer nocontent">
  
  
    <p>Except as otherwise noted, the content of this page is licensed under the <a href="https://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 License</a>, and code samples are licensed under the <a href="https://www.apache.org/licenses/LICENSE-2.0">Apache 2.0 License</a>. For details, see our <a href="https://developers.google.com/terms/site-policies">Site Policies</a>. Java is a registered trademark of Oracle and/or its affiliates.</p>
  

  
    
    <p class="devsite-content-footer-date" itemprop="datePublished" content="2018-08-23T03:27:57.801800">
      
      Last updated August 23, 2018.
    </p>
  

</div>

        </article>