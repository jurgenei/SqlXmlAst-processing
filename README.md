# SqlXmlLin
Processing stylesheets for rewriting SqlXmlAst into something useful, some ideas:

* Data Lineage Graphs
* Visualisation
* Code Style Checks

# Tool Chain
Ant is the build tool being used (yes its old, but dont want to move to maven, gradle, sbt yet)
A basic conversion chain looks like this:
```xml
   <target name="oracle.cons">
        <sql2ast dir="cons"/>
        <ast2tidy dir="cons"/>
        <tidy2html dir="cons"/>
   </target>
```
Build definitions are brief thanks to use of Macros under the hood.

## sql2ast
The sql2ast task converts sql to abstact syntax trees. the ast format could be considered way too rich to be useful. Around tokens where the parser meets the lexer some interesting things happen. During parsing each token gets wrapped by `<t>` and `</t>` tags and white space by `<c:LEX_RULE_NAME>` and `</c:LEX_RULE_NAME>`. As you can imagine a `simple a.b_` (_ is a space) will already be `<id-expression><t>a</t><t>.</t><t>b</t><c:SPACES>_</c:SPACES></id-expression>`. To make such sequences easier we'll rewrite them in ast2tidy

## ast2tidy
The ast2tidy task rewites above sentence into `<id-expression><id>a</id><t>.</t><id>b</id></id-expression><c:c> </c:c>`, note:
* a,b become both id which make in id picking in downstream stylesheets easier.
* spaces are shuffled to later point, yet preserving original whitespace layout.

## tidy2html
The tidy2html task converts tidy format into nice syntax colored format, yet preserving original layout.

## tidy2lin
The tidy2lin task converts tidy format into rdf triplets which describe data lineage. [todo] design


# See Also
*  [SqlXmlAst](https://github.com/jurgenei/SqlXmlAst/blob/master/README.md)
*  [SqlXmlPub](https://github.com/jurgenei/SqlXmlPub/blob/master/README.md)
