[#ftl strict_vars=true]
[#--
/* Copyright (c) 2008-2019 Jonathan Revusky, revusky@javacc.com
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright notices,
 *       this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name Jonathan Revusky, Sun Microsystems, Inc.
 *       nor the names of any contributors may be used to endorse 
 *       or promote products derived from this software without specific prior written 
 *       permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */
 --]
/* Generated by: ${generated_by}. Do not edit. ${filename} */
[#if explicitPackageName?has_content]
package ${explicitPackageName};
[#elseif grammar.parserPackage?has_content]
package ${grammar.parserPackage};
[/#if]
[#if grammar.options.freemarkerNodes]
import freemarker.template.*;
[/#if]

import java.util.*;
  
 @SuppressWarnings("rawtypes")  
public class ${grammar.baseNodeClassName} implements Node {

[#if !grammar.options.hugeFileSupport && !grammar.options.userDefinedLexer]
       private FileLineMap fileLineMap;
       
       public FileLineMap getFileLineMap() {
           return fileLineMap; 
       }
       
       public void setInputSource(FileLineMap fileLineMap) {
          this.fileLineMap = fileLineMap;
       }
[#else]
       private String inputSource;
       
       public String getInputSource() {
           return inputSource;
       }
       
       public void setInputSource(String inputSource) {
          this.inputSource = inputSource;
       }
       
 [/#if]       

    
    static private Class listClass = ArrayList.class;

	static public void setListClass(Class<? extends List> listClass) {
        ${grammar.baseNodeClassName}.listClass = listClass;
    }

    @SuppressWarnings("unchecked")    
    private List<Node> newList() {
        try {
           return (List<Node>) listClass.getDeclaredConstructor().newInstance();
        } catch (Exception e) {
           throw new RuntimeException(e);
        }
    }
    
    protected Node parent;
    protected List<Node> children = newList();
    
    private int beginLine, beginColumn, endLine, endColumn;
    private Map<String,Object> attributes;
    private boolean unparsed;
    
    public boolean isUnparsed() {
       return this.unparsed;
    }
    
    public void setUnparsed(boolean unparsed) {
        this.unparsed = unparsed;
    } 

[#if grammar.options.nodeUsesParser]    
    protected ${grammar.parserClassName} parser;
    public ${grammar.baseNodeClassName}(${grammar.parserClassName} parser) {
        this.parser = parser;
    }

    public ${grammar.baseNodeClassName}() {
    }

[/#if]

[#if grammar.options.faultTolerant]

    private ParseException parseException;
    
    public ParseException getParseException() {return parseException;}
    
    public void setParseException(ParseException parseException) {this.parseException = parseException;}
    

[/#if]

    public void open() {
    }

    public void close() {}

    public void setParent(Node n) {
        parent = n;
    }

    public Node getParent() {
        return parent;
    }

    public void addChild(Node n) {
        children.add(n);
        n.setParent(this);
    }
    
    public void addChild(int i, Node n) {
        children.add(i, n);
        n.setParent(this);
    }

    public Node getChild(int i) {
        return children.get(i);
    }

    public void setChild(int i, Node n) {
        children.set(i, n);
        n.setParent(this);
    }
    
    public Node removeChild(int i) {
        return children.remove(i);
    }
    
    public boolean  removeChild(Node n) {
        return children.remove(n);
    }
    
    public void clearChildren() {
        children.clear();
    }

    public int getChildCount() {
        return children.size();
    }
    
    public List<Node> children() {
        return Collections.unmodifiableList(children);
    }
    
    public Object getAttribute(String name) {
        return attributes == null ? null : attributes.get(name); 
    }
     
    public void setAttribute(String name, Object value) {
        if (attributes == null) {
            attributes = new HashMap<String, Object>();
        }
        attributes.put(name, value);
    }
     
    public boolean hasAttribute(String name) {
        return attributes == null ? false : attributes.containsKey(name);
    }
     
    public Set<String> getAttributeNames() {
        if (attributes == null) return Collections.emptySet();
        return attributes.keySet();
    }
    
    public int getBeginLine() {
        if (beginLine <= 0) {
            if (!children.isEmpty()) {
                beginLine = children.get(0).getBeginLine();
                beginColumn = children.get(0).getBeginColumn();
            }
        }
        return beginLine;
    }
     
    public int getEndLine() {
        if (endLine <=0) {
            if (!children.isEmpty()) {
                Node last = children.get(children.size()-1);
                endLine = last.getEndLine();
                endColumn = last.getEndColumn();
            }
        }
        return endLine;
    }
    
    public int getBeginColumn() {
        if (beginColumn <= 0) {
            if (!children.isEmpty()) {
                beginLine = children.get(0).getBeginLine();
                beginColumn = children.get(0).getBeginColumn();
            }
        }
        return beginColumn;
    }
    
    public int getEndColumn() {
        if (endColumn <=0) {
            if (!children.isEmpty()) {
                Node last = children.get(children.size()-1);
                endLine = last.getEndLine();
                endColumn = last.getEndColumn();
            }
        }
        return endColumn;
    }
     
    public void setBeginLine(int beginLine) {
        this.beginLine = beginLine;
    }
     
    public void setEndLine(int endLine) {
        this.endLine = endLine;
    }
     
    public void setBeginColumn(int beginColumn) {
        this.beginColumn = beginColumn;
    }
     
    public void setEndColumn(int endColumn) {
        this.endColumn = endColumn;
    }
     
[#if grammar.options.freemarkerNodes]    
    public TemplateSequenceModel getChildNodes() {
        SimpleSequence seq = new SimpleSequence();
        for (Node child : children) {
            seq.add(child);
        }
        return seq;
    }
    
    public TemplateNodeModel getParentNode() {
        return this.parent;
    }
    
    public String getNodeName() {
         return this.getClass().getSimpleName();
    }
    
    public String getNodeType() {
        return "";
    }
    
    public String getNodeNamespace() {
        return null;
    }
    
    public String getAsString() throws TemplateModelException {
        StringBuilder buf = new StringBuilder();
        if (children != null) {
	        for (Node child : children) {
	            buf.append(child.getAsString());
	            buf.append(" ");
	        }
	    }
        return buf.toString();
    }
[/#if]    
    
    public String toString() {
        StringBuilder buf=new StringBuilder();
        for(Token t : Nodes.getRealTokens(this)) {
            buf.append(t);
        }
        return buf.toString();
    }
    
}
