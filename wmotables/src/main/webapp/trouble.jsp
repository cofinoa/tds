<%@ include file="/WEB-INF/views/include/tablibs.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <html>
  <head>
   <title><spring:message code="global.title"/>: The Trouble with BUFR</title>
<%@ include file="/WEB-INF/views/include/resources.jsp" %>
  </head>
  <body> 
<%@ include file="/WEB-INF/views/include/header.jsp" %>
   
   <h3>The Trouble with BUFR</h3>
   <p><em>Draft Aug 6, 2008</em></p>
   <p><em>John Caron, Unidata/UCAR</em></p>
   <ol>
    <li><b>Specification of BUFR encoding is not clear enough</b></li>
    <ol>
     <li><a href="http://www.wmo.int/pages/prog/www/WMOCodes/Operational/BUFR/FM94REG-11-2007.pdf">BUFR Code Form and Regulations</a> is a set of &quot;Regulations&quot; that describes the format for edition 3 and 4 in a formal way.</li>
     <ul>
       <li>The formal language is not easy to read and translate into software. An actual  grammer would be more  concise and unambiguous.</li>
       <li>We still see BUFR messages in edition 2 and before, and there are no easily found WMO docs  online for edition 0-2.</li>
     </ul>
     <li><a href="http://www.wmo.int/pages/prog/www/WMOCodes/ManualCodesGuides.html">Guide to WMO Table-Driven Code Forms: FM 94 BUFR and FM 95 CREX</a> is an informal tutorial, not a specification. Given the limits of 1), it is quite indispensible.</li>
    </ol>

    <li><b>There is no reference implementation for validation that a BUFR message is correctly formed.</b></li>
    <p>For example, I am seeing messages &quot;in the field&quot; where the data length is not an even number of bytes, despite (1) stating it must be.</p>
    <p>I expect that coders &quot;validate&quot; against their own decoders. This makes the format specification ad-hoc, dependent upon specific software. This was also noted in the ET/DR&amp;C May 2006 final report, section 6.7.</p>
    <p>There is a <a href="http://www.ecmwf.int/products/data/d/check/">validator service at ECMWF</a> which is useful, although its tables are limited.</p>

    <li>Table-driven parsing is extremely brittle.</b></li>
    <p>There is no way to be completely sure if a decoder is using the right table. If a decoder does not use the exact version of the coders' tables, the values will be wrong, and may very well be silently wrong. If bit widths are wrong, the message is unparseable.</p>
    <p>Table C operators can modify the encoding of the values. If those are incorrect or misunderstood, all values in the message may be incorrect.</p>
    <p>The presence of an element descriptor that is not understood makes the entire message unreadable.</p>

    <li><b>There is no authoritative registry of Tables.</b></li>
    <p>There is no place that versioned, canonical, machine-readable tables are registered. Only the latest WMO master table is apparrently available online, and it is not machine reable. It is quite difficult and error-prone to extract machine-readable tables for the WMO Word and PDF docs. These docs apparenyly have typos in them, for example element 0-22-39 in the <a href="http://www.wmo.int/pages/prog/www/WMOCodes/Operational/BUFR/BufrTabB-11-2007.pdf">version 13 Table B document</a>.</p>
    <p>Local tables must be found in an ad-hoc way. There is no way to confirm if you have the correct table.</p>
    <p>This makes problem #3 very serious as an exchange format. As an archive format, probably not tenable, as we will be unable to confidently parse arbitrary BUFR messages.</p>

    <li><b>Table versions</b></li>
    <p>If new versions of the WMO master table can only add new elements, this  would be very good news. It would mean that one really only needs the  latest version of the table. Is there somewhere that is explicitly  stated in the WMO BUFR specification?    The worry that I have is that if a mistake is made in a published  version of a table, and is used to code a BUFR message, that message  will be incorrectly read by a decoder using the corrected version of the  table. Theres no way to unambiguously know what table the coder used. </p>

    <li><b>Use of local tables</b></li>
    <p>The use of local entries for both B and D should be restricted to x=48-63 and y=192-255 inclusive.</p>
    <p>An examination of ECMWF tables may indicate local use of some table entries not in the local range. For example comparing  ECMWF tables B000 00000 00098 002 001.TXT vs B000 00000 00098 013 001.TXT, the following entries are different:</p>
    <pre> 1-22, 4-24, 7-190, 21-17, 25-30 </pre>
    <ul>
     <li>1-22 has different bit width</li>
     <li>4-24 has different reference / bit width</li>
     <li>7-190 does not appear in table 13</li>
     <li>21-17 has different reference </li>
     <li>25-30 has completely changed </li>
    </ul>
    <p>If master entries are allowed to be overrided locally, then a generic parser MUST have the local table. If they cannot be overriden, then the absence of any local elements means that the master table can be used in confidence.</p>
    <p>If local tables must always be used, then the local center must be contacted and tables obtained. This is akin to reading files written with unformatted binary FORTRAN writes. The only way to read such files is to obtain documentaion or the actual program that made the write. This makes BUFR files effectively NOT self-describing.</p>

    <li><b>BUFR is too complex without real gain.</b></li>
    <p>Some of the complexity of the BUFR format comes from an ad-hoc compression scheme that is out-of-date. The brittleness of the encoding format is partly caused by trying to make the record as small as possible. Its likely that using an external compression on a message will acheive the same goal.</p>
    <p>The BUFR &quot;information model&quot; and its encoding have been convolved to make each dependent on the other. A more modern solution is to clearly separate the two. </p> 
    <p>The BUFR &quot;information model&quot; is not constrained enough. If unnecessarily allows the DDS to change in each message. An archival system must read each message and assign it to the correct dataset.</p>
    <p><strong>7.1 Turning on and off Coordinates </strong></p>
    <p>Reference Section 3.1.2.2</p>
    <p>Might be useful in an actual streaming environment. In fact, standard messages are being sent, and there are much simpler and less error-prone ways to specify coordinate values. Pre-defined data model vs &quot;on-the-fly&quot; data model. In fact OTF data-model are too hard to use. 1.5M data schemas per day?</p>
    <p>With some help from humans, these standard messages ccan be translated into databases, netcdf, XML, etc. and maintain semantics. This implies that there is no need for this kind of streaming data schemas.</p>
    <p>Bandwidth is wasted on this. Makes it much harder to parse.</p>
    <p>Meaning of data now depends on the order the variables are in.</p>
    <p>Coordinate ranges defined by &quot;back to back&quot; identical coordinates (see L3-25). &quot;There is not much a general decoder program can do with this coordinate information&quot;.</p>
    <p>For example (ISXAB40KWNO.bufr):</p>
    <pre>
    ISXA40 KWNO 071800     Category= 7 Synoptic features 7.0 local= 0     Center= NCEP /  Central Operations 7.3   ...
    0-5-21: Bearing_or_azimuth units=Degree true scale=2 refVal=0 nbits=16 
    0-5-21: Bearing_or_azimuth units=Degree true scale=2 refVal=0 nbits=16 
    0-19-3: Wind_SPD_threshold units=m s-1 scale=0 refVal=0 nbits=8 
    0-19-9: Effective_radius_with_respect_to_wind_speeds_above_threshold units=m scale=-3 refVal=0 nbits=12 
    0-5-21: Bearing_or_azimuth units=Degree true scale=2 refVal=0 nbits=16 
    0-5-21: Bearing_or_azimuth units=Degree true scale=2 refVal=0 nbits=16 
    0-19-3: Wind_SPD_threshold units=m s-1 scale=0 refVal=0 nbits=8 
    0-19-9: Effective_radius_with_respect_to_wind_speeds_above_threshold units=m scale=-3 refVal=0 nbits=12 
    0-5-21: Bearing_or_azimuth units=Degree true scale=2 refVal=0 nbits=16 
    0-5-21: Bearing_or_azimuth units=Degree true scale=2 refVal=0 nbits=16 
    0-19-3: Wind_SPD_threshold units=m s-1 scale=0 refVal=0 nbits=8 
    0-19-9: Effective_radius_with_respect_to_wind_speeds_above_threshold units=m scale=-3 refVal=0 nbits=12 
    </pre>
    <p><strong>7.2. associated variables seem like a kludge</strong></p>
    <p>6 bits of meaning for 1 bit of data. example of (9).</p>

    <li><b>Lack of name/value attributes</b></li>
    <p>Arbitrary key-values are lacking. The closest are &quot;comments&quot; using 2 05 Y which allows inclusion of arbitrary character data. The Y allows variable length. (Does our hashcode make this into seperate message type ??)</p>
    <p>While one could add key-values on top of this coomect mechanism,i t would be non-standard. </p>
    <p>Users seem to use standard templates without additional commenting, which makes the metadata impoverished.</p>

    <li><b>Multiple fields with same name</b></li>
    <p>The same name can be used in different tables. Im not sure how often this actually happpens.</p>
   </ol>
   <h5>Remedies</h5>
   <ol>
    <li>BUFR messages intended for exchange MUST register canonical, versioned, machine-readable instances of their tables with WMO. XML would be a good choice. </li>
    <li>A checksum of the table could be embedded in the BUFR message, to be matched against one in the registry.</li>
    <li>A  grammer for BUFR should be written.</li>
    <li>A reference implemenatation of a decoder should be written. A web service providing decoded output  would be very useful. It should use the canonical tables, and would be a motivation for users to register their local tables.</li>
    <li>The master table should only add new entries, and correct or clarify names and units in existing elements. Scale/Reference/BitWidth must never change, and elements must never be deleted. This should be explicitly stated in the BUFR spec.</li>
    <li>Local tables must never use entries outside the local range. This should be explicitly stated in the BUFR spec.</li>
   </ol>

<%@ include file="/WEB-INF/views/include/footer.jsp" %>
  </body>
 </html>
