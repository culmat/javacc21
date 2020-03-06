/* Generated by: ${generated_by}. ${filename} */
[#if grammar.parserPackage?has_content]
package ${grammar.parserPackage};
[/#if]

[#set classname = filename?substring(0, filename?length-5)]
[#set options = grammar.options]

import java.io.*;
import java.util.ArrayList;


public class ${classname} {

    /** The buffersize parameter is only there for backward compatibility. It is currently ignored. */
    public ${classname}(Reader reader, int startline, int startcolumn, int buffersize) {
        this(reader, startline, startcolumn);
     }

    public ${classname}(Reader reader, int startline, int startcolumn) {
        this.wrappedReader = new WrappedReader(reader, startline, startcolumn);
    }

    public ${classname}(Reader reader) {
        this(reader, 1, 1, 4096);
    }


    private class LocationInfo {
         int ch=-1, line, column;
    }

   private ArrayList<LocationInfo> locationInfoBuffer = new ArrayList<>();
   
   private LocationInfo getLocationInfo(int pos) {
   
       while (pos >= locationInfoBuffer.size()) {
            locationInfoBuffer.add(null);
       }
       
       LocationInfo linfo = locationInfoBuffer.get(pos);
       
       if (linfo == null) {
           linfo = new LocationInfo();
           locationInfoBuffer.set(pos, linfo); 
       }
       
       return linfo;
   
   }
    private void maybeResizeBuffer() {
         if (tokenBegin > 2048) {
         // If we are starting a new token this far into the buffer, we throw away 1024 initial bytes
         // Totally ad hoc, maybe revisit the numbers, though it likely doesn't matter very much.
              ArrayList<LocationInfo> newBuffer = new ArrayList<>(locationInfoBuffer.size());
              for (int i=1024; i<locationInfoBuffer.size(); i++) {
                  newBuffer.add(locationInfoBuffer.get(i));
              }
              locationInfoBuffer = newBuffer;
              bufpos -=1024;
              tokenBegin -=1024;
         }
    }

    private final int bufsize = 4096;
    private int tokenBegin;
    private int bufpos = -1;
    private WrappedReader wrappedReader;
    private int backupAmount;
    
    
     int getBeginColumn() {
        return getLocationInfo(tokenBegin).column;
    }
    
        int getBeginLine() {
        return getLocationInfo(tokenBegin).line;
    }
   
        int getEndColumn() {
        return getLocationInfo(bufpos).column;
    }
    
        int getEndLine() {
        return getLocationInfo(bufpos).line;
    }
    
   
     public void backup(int amount) {
        backupAmount += amount;
        bufpos -= amount;
        if (bufpos  < 0) {
//              bufpos = 0;
            bufpos += bufsize;
        } 
    }

    
        
    /**
     * sets the size of a tab for location reporting 
     * purposes, default value is 8.
     */
    public void setTabSize(int i) {wrappedReader.tabSize = i;}
    
    /**
     * returns the size of a tab for location reporting 
     * purposes, default value is 8.
     */
    public int getTabSize() {return wrappedReader.tabSize;}
    
     public int readChar() throws IOException {
        if (backupAmount > 0) {
           --backupAmount;
           ++bufpos;
           if (bufpos == bufsize) { //REVISIT!
               bufpos = 0;
           }
           return getLocationInfo(bufpos).ch;         
        }
        ++bufpos;
         int ch = wrappedReader.read();
         if (ch ==-1) {
           --bufpos;
          backup(0);
          if (tokenBegin <0) {
              tokenBegin = bufpos;
          }
           throw new IOException();
         }
        return ch;
    }

    /** Get token literal value. */
    public String getImage() {
        if (bufpos >= tokenBegin) { 
              StringBuilder buf = new StringBuilder();
              for (int i =tokenBegin; i<= bufpos; i++) {
                  buf.append((char) getLocationInfo(i).ch);
              }
              return buf.toString();
        }
        else { 
             StringBuilder buf = new StringBuilder();
             for (int i=tokenBegin; i<bufsize; i++) {
                  buf.append((char) getLocationInfo(i).ch);
             }
             for (int i=0; i<=bufpos; i++) {
                  buf.append((char) getLocationInfo(i).ch);
             }
             return buf.toString();
        }
    }
    
    public char[] getSuffix(final int len) {
        char[] ret = new char[len];
        if ((bufpos + 1) >= len) { 
             int startPos = bufpos - len +1;
             for (int i=0; i<len; i++) {
                 ret[i] = (char) getLocationInfo(startPos+i).ch;
             }
        }
        else {
            int startPos = bufsize - (len-bufsize-1);
            int lengthToCopy = len - bufpos -1;
            for (int i=0; i<lengthToCopy; i++) {
                ret[i] = (char) getLocationInfo(startPos+i).ch;
            }
            lengthToCopy = len - bufpos -1;
            int destPos = len-bufpos-1;
            for (int i=0; i<lengthToCopy; i++) {
                ret[destPos+i] = (char) getLocationInfo(i).ch;
            }
            
        }
        return ret;
    } 

  
    public int beginToken() { 
            if (backupAmount > 0) {
            --backupAmount;
           if (++bufpos == bufsize)
                bufpos = 0;
           tokenBegin = bufpos;
            return getLocationInfo(bufpos).ch;
        }
        tokenBegin = 0;
        bufpos = -1;
        try {        
        	return readChar();
        } catch (IOException ioe) {
            return -1;
        }
    }

    private class WrappedReader extends Reader {
    
        StringBuilder buf;
        Reader nestedReader;
        StringBuilder pushBackBuffer = new StringBuilder();
        int column = 0, line = -1, tabSize =8;
        private boolean prevCharIsCR, prevCharIsLF;
        
        
        WrappedReader(Reader nestedReader, int startline, int startcolumn) {
            this.nestedReader = nestedReader;
           line = startline;
            column = startcolumn - 1;
         }
         
        private int nextChar() throws IOException {
            return nestedReader.read();
        }

        
        
        public void close() throws IOException {
            nestedReader.close();
        }
        
        public int read() throws IOException {
        
             int ch;
             int pushBack = pushBackBuffer.length();
             if (pushBack >0) {
                 ch = pushBackBuffer.charAt(pushBack -1);
                 pushBackBuffer.setLength(pushBack -1);
                 updateLineColumn(ch);
                 return ch;
             }
             ch = nextChar();
             
             
//             if (ch == '\r' || ch == '\n') {
//                 ch = handleNewLine(ch);
//             }
             
[#if grammar.options.javaUnicodeEscape]             
             if (ch == '\\') {
                 ch = handleBackSlash();
             } else {
                 lastCharWasUnicodeEscape = true;
             }
[/#if]
             updateLineColumn(ch);
             return ch;
        }
        
        public int read (char[] cbuf, int off, int len) throws IOException {
              throw new UnsupportedOperationException();
        }
        
        void pushBack(int ch) {
           pushBackBuffer.append((char) ch);
        }
        
        int addedNewLines;
        StringBuilder pendingNewLines = new StringBuilder();
        
        private int handleNewLine(int ch) throws IOException {
            int nextChar = nextChar();
            if (nextChar != '\n' && nextChar != '\r') {
                pushBack(nextChar);
            }
            return ch;
        }
        
        private int handleTab() {
             column--;
             column += (tabSize - (column % tabSize));
             return '\t';
        }
        
	    private void updateLineColumn(int c) {
           getLocationInfo(bufpos).ch = c;
	    
	        column++;
	        if (prevCharIsLF) {
	            prevCharIsLF = false;
	            ++line;
	            column = 1;
	        }
	        else if (prevCharIsCR) {
	            prevCharIsCR = false;
	            if (c == '\n') {
	                prevCharIsLF = true;
	            }
	            else {
	                ++line;
	                column = 1;
	            }
	        }
	        switch(c) {
	            case '\r' : 
	                prevCharIsCR = true;
	                break;
	            case '\n' : 
	                prevCharIsLF = true;
	                break;
	            default : break;
	        }
	        getLocationInfo(bufpos).line = line;
	        getLocationInfo(bufpos).column = column;
	    }

        
[#if grammar.options.javaUnicodeEscape]
        StringBuilder hexEscapeBuffer = new StringBuilder();
        boolean lastCharWasUnicodeEscape;
        
        private int handleBackSlash() throws IOException {
               int nextChar = nextChar();
               if (nextChar != 'u') {
                   pushBack(nextChar);
                   lastCharWasUnicodeEscape = false;
                   return '\\';
               }
               hexEscapeBuffer = new StringBuilder("\\u");
               while (nextChar == 'u') {
                  nextChar = nextChar();
                  hexEscapeBuffer.append((char) nextChar);
               }
              // NB: There must be 4 chars after the u and 
              // they must be valid hex chars! REVISIT.
               for (int i =0;i<3;i++) {
                   hexEscapeBuffer.append((char) nextChar());
               }
               String hexChars = hexEscapeBuffer.substring(hexEscapeBuffer.length() -4);
               lastCharWasUnicodeEscape = true;
               return Integer.parseInt(hexChars, 16);
        }
[/#if]        
        
    }
}

