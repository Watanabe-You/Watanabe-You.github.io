<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="application/xml" href="framexs.xsl"?>
<!--
XSLTで実現するフレームワーク framexs
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xh="http://www.w3.org/1999/xhtml" xmlns:framexs="urn:framexs" version="1.0">
	<xsl:output encoding="UTF-8" media-type="text/html" method="html" doctype-system="about:legacy-compat"/>

	<!-- skeleton_locが指定されればXHTMLテンプレート処理を行う -->
	<xsl:param name="skeleton_loc" select="/processing-instruction('framexs.skeleton')"/>
	<xsl:param name="properties_loc" select="/processing-instruction('framexs.properties')"/>
	<xsl:param name="framexs.base" select="/processing-instruction('framexs.base')"/>
	<xsl:param name="framexs.addpath" select="concat($skeleton_loc, '/../')"/>

	<xsl:variable name="root" select="/"/>
	<xsl:variable name="xhns" select="'http://www.w3.org/1999/xhtml'"/>
	<xsl:variable name="fmxns" select="'urn:framexs'"/>
	<xsl:variable name="empty" select="''"/>
	<xsl:variable name="version" select="'1.11.0'"/>
	
	<xsl:template match="/">
		<xsl:message>framexs <xsl:value-of select="$version"/></xsl:message>
		<!-- 基本的な処理分けを行う。XHTMLか一般XMLか -->
		<xsl:choose>
			<xsl:when test="$skeleton_loc and namespace-uri(*[1]) = $fmxns">
				<xsl:apply-templates select="document($skeleton_loc)/*">
					<xsl:with-param name="content" select="document(/framexs:tunnel/@content)"/>
					<xsl:with-param name="properties" select="document($properties_loc)/framexs:properties"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$skeleton_loc and namespace-uri(*[1]) = $xhns">
				<xsl:message>exec content</xsl:message>
				<xsl:apply-templates select="document($skeleton_loc)/*">
					<xsl:with-param name="content" select="$root"/>
					<xsl:with-param name="properties" select="document($properties_loc)/framexs:properties"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>一般XML</xsl:message>
				<html>
					<head>
						<title>エラー</title>
					</head>
					<body>
						<p>framexsバージョン:<xsl:value-of select="$version"/></p>
						<p>テンプレートは名前空間(<xsl:value-of select="$xhns"/>)を持ったXHTMLを指定してください</p>
					</body>
				</html>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--  -->
	<xsl:template match="xh:*" mode="content">
		<xsl:element name="{name()}">
			<xsl:apply-templates mode="content" select="@*"/>
			<xsl:apply-templates mode="content" select="node()"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="@* | node()" mode="content">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="content"/>
			<xsl:apply-templates mode="content"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xh:*" mode="search-id">
		<xsl:param name="id"/>
		<xsl:param name="self" select="false()"/>
		<xsl:choose>
			<xsl:when test="@id = $id">
				<xsl:choose>
					<xsl:when test="$self">
						<xsl:apply-templates mode="content" select="."/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="content" select="node()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="xh:*" mode="search-id">
					<xsl:with-param name="id" select="$id"/>
					<xsl:with-param name="self" select="$self"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="xh:*[@framexs:id-d]">
		<xsl:param name="content"/>
		<xsl:message>id-d</xsl:message>
		<xsl:apply-templates mode="search-id" select="$content/xh:html">
			<xsl:with-param name="id" select="@framexs:id-d"/>
			<xsl:with-param name="self" select="false()"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="xh:*[@framexs:id-sd]">
		<xsl:param name="content"/>
		<xsl:apply-templates mode="search-id" select="$content/xh:html">
			<xsl:with-param name="id" select="@framexs:id-sd"/>
			<xsl:with-param name="self" select="true()"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="xh:*[@framexs:fetch-sd]">
		<xsl:param name="content"/>
		<xsl:variable name="name" select="@framexs:fetch-sd"/>
		<xsl:for-each select="$content/processing-instruction('framexs.fetch')">
			<xsl:if test="$name = substring-before(.,' ')">
				<xsl:apply-templates mode="content" select="document(substring-after(.,' '), $content)/*"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="xh:*[@framexs:fetch-d]">
		<xsl:param name="content"/>
		<xsl:variable name="name" select="@framexs:fetch-d"/>
		<xsl:for-each select="$content/processing-instruction('framexs.fetch')">
			<xsl:if test="$name = substring-before(.,' ')">
				<xsl:apply-templates mode="content" select="document(substring-after(.,' '), $content)/*[1]/*"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!--  -->
	<xsl:template match="*">
		<xsl:copy-of select="."/>
	</xsl:template>
	<!--framexs要素-->
	<xsl:template match="framexs:title">
		<xsl:param name="content"/>
		<xsl:value-of select="$content/xh:html/xh:head/xh:title"/>
	</xsl:template>
	<xsl:template match="framexs:script">
		<xsl:param name="content"/>
		<xsl:for-each select="$content/xh:html/xh:head/xh:script">
			<xsl:choose>
				<xsl:when test="@src">
					<xsl:element name="script">
						<xsl:call-template name="replacepath">
							<xsl:with-param name="current" select="."/>
						</xsl:call-template>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="framexs:style">
		<xsl:param name="content"/>
		<xsl:for-each select="$content/xh:html/xh:head/xh:style">
			<xsl:element name="style">
				<xsl:call-template name="replacepath">
					<xsl:with-param name="current" select="."/>
				</xsl:call-template>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="framexs:link">
		<xsl:param name="content"/>
		<xsl:for-each select="$content/xh:html/xh:head/xh:link">
			<xsl:element name="link">
				<xsl:call-template name="replacepath">
					<xsl:with-param name="current" select="."/>
				</xsl:call-template>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="framexs:meta[@name]">
		<xsl:param name="content"/>
		<xsl:variable name="name" select="@name"/>
		<xsl:for-each select="$content/xh:html/xh:head/xh:meta">
			<xsl:if test="@name = $name">
				<xsl:value-of select="@content"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="framexs:meta[@property]">
		<xsl:param name="content"/>
		<xsl:variable name="property" select="@property"/>
		<xsl:for-each select="$content/xh:html/xh:head/xh:meta">
			<xsl:if test="@property = $property">
				<xsl:value-of select="@content"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
		<xsl:template match="framexs:if-meta[@name]">
		<xsl:param name="content"/>
		<xsl:variable name="name" select="@meta-name"></xsl:variable>
		<xsl:variable name="if-meta" select="."></xsl:variable>
		<xsl:for-each select="$content/xh:html/xh:head/xh:meta">
			<xsl:if test="$name = @name">
				<xsl:apply-templates select="$if-meta/*">
					<xsl:with-param name="content" select="$content"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="framexs:if-meta[@name and @content]">
		<xsl:param name="content"/>
		<xsl:variable name="name" select="@name"/>   
		<xsl:variable name="value" select="@content"/>
		<xsl:variable name="if-meta" select="."/>
		<xsl:for-each select="$content/xh:html/xh:head/xh:meta">
			<xsl:if test="@name = $name and @content = $value">
				<xsl:apply-templates select="$if-meta/*">
					<xsl:with-param name="content" select="$content"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="framexs:if-meta[@property]">
		<xsl:param name="content"/>
		<xsl:variable name="property" select="@meta-property"/>
		<xsl:variable name="if-meta" select="."/>
		<xsl:for-each select="$content/xh:html/xh:head/xh:meta">
			<xsl:if test="$property = @property">
				<xsl:apply-templates select="$if-meta/*">
					<xsl:with-param name="content" select="$content"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="framexs:if-meta[@property and @content]">
		<xsl:param name="content"/>
		<xsl:variable name="property" select="@property"/>
		<xsl:variable name="value" select="@content"/>
		<xsl:variable name="if-meta" select="."/>
		<xsl:for-each select="$content/xh:html/xh:head/xh:meta">
			<xsl:if test="@property = $property and @content = $value">
				<xsl:apply-templates select="$if-meta/*">
					<xsl:with-param name="content" select="$content"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="framexs:if-property[@name]">
		<xsl:param name="content"/>
		<xsl:param name="properties"/>
		<xsl:variable name="name" select="@name"></xsl:variable>
		<xsl:variable name="if-property" select="."></xsl:variable>
		<xsl:for-each select="$properties/framexs:property">
			<xsl:if test="@name = $name">
				<xsl:apply-templates select="$if-property/*">
					<xsl:with-param name="content" select="$content"/>
					<xsl:with-param name="properties" select="$properties"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="framexs:property[@name]">
		<xsl:param name="properties"/>
		<xsl:variable name="name" select="@name"/>
		<xsl:if test="not($properties = '')">
			<xsl:for-each select="$properties/framexs:property">
				<xsl:if test="@name = $name">
					<xsl:copy-of select="node()"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template match="framexs:attribute[@name]">
		<xsl:param name="content"/>
		<xsl:param name="properties"/>
		<xsl:attribute name="{@name}">
			<xsl:apply-templates>
				<xsl:with-param name="content" select="$content"/>
				<xsl:with-param name="properties" select="$properties"/>
			</xsl:apply-templates>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="framexs:*"></xsl:template>
	
	<!-- コンテンツにframexs.baseがあるならbaseのhrefを上書きする -->
	<xsl:template match="xh:base[@framexs:base='on']">
		<xsl:element name="base">
			<xsl:for-each select="@*">
				<xsl:copy-of select="."/>
				<xsl:if test="name() = 'href' and $framexs.base">
					<xsl:attribute name="href"><xsl:value-of select="$framexs.base"/></xsl:attribute>
				</xsl:if>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	<!-- 何も出力しない -->
	<xsl:template match="xh:*[@framexs:print='no']"/>
	
	<xsl:template match="xh:title">
		<xsl:param name="content"/>
		<xsl:param name="properties"/>
		<xsl:element name="title">
			<xsl:value-of select="$content/xh:html/xh:head/xh:title/text()"/>
			<xsl:apply-templates>
				<xsl:with-param name="properties" select="$properties"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>


	<!-- meta要素は特別な扱いをする -->
	<xsl:template name="metatemplate">
		<xsl:param name="target"/>
		<xsl:param name="base"/>
		<xsl:element name="meta">
			<xsl:for-each select="@*">
				<xsl:choose>
					<xsl:when test="name() = 'content'">
						<xsl:attribute name="{name()}"><xsl:value-of select="$target/@content"/><xsl:value-of select="$base/@content"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template match="xh:meta[@framexs:fix]">
		<xsl:element name="{name()}">
			<xsl:for-each select="@*[not(namespace-uri(.) = $fmxns)]">
				<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template match="xh:meta[@name and not(@framexs:fix)]">
		<xsl:param name="content"/>
		<xsl:variable name="base" select="."/>
		<xsl:for-each select="$content/xh:html/xh:head/xh:meta[@name]">
			<xsl:variable name="target" select="."/>
			<xsl:if test="$base/@name=$target/@name">
				<xsl:call-template name="metatemplate">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="target" select="$target"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="xh:meta[@property and not(@framexs:fix)]">
		<xsl:param name="content"/>
		<xsl:variable name="base" select="."/>
		<xsl:for-each select="$content/xh:html/xh:head/xh:meta[@property]">
			<xsl:variable name="target" select="."/>
			<xsl:if test="$base/@property=$target/@property">
				<xsl:call-template name="metatemplate">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="target" select="$target"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<!-- パスの解決アルゴリズム -->
	<xsl:template name="replacepath">
		<xsl:param name="current"/>
		<xsl:for-each select="$current/@*">
			<xsl:choose>
				<xsl:when test="name() = 'src' or name() = 'href' or name() = 'data'">
					<xsl:variable name="absolute">
						<xsl:call-template name="is-absolute">
							<xsl:with-param name="uri" select="."></xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<xsl:attribute name="{name()}">
						<xsl:if test="not($absolute = 'true') and not(starts-with(., '#'))">
							<xsl:value-of select="$framexs.addpath"/>
						</xsl:if>
						<xsl:value-of select="."/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="namespace-uri() != 'urn:framexs'">
						<xsl:copy-of select="."/>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<!-- 一般のXHTML要素に対応する -->
	<xsl:template match="xh:*">
		<xsl:param name="content"/>
		<xsl:param name="properties"/>
		<xsl:element name="{name()}">
			<xsl:apply-templates select="framexs:attribute">
				<xsl:with-param name="content" select="$content"/>
				<xsl:with-param name="properties" select="$properties"/>
			</xsl:apply-templates>
			<xsl:call-template name="replacepath">
				<xsl:with-param name="current" select="."/>
			</xsl:call-template>
			<xsl:apply-templates>
				<xsl:with-param name="content" select="$content"/>
				<xsl:with-param name="properties" select="$properties"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	<!--文字列を受け取ってそれが絶対URIかを判定する-->	
	<xsl:template name="is-absolute">
		<xsl:param name="uri" />

		<xsl:variable name="uri-has-scheme">
			<xsl:call-template name="is-valid-scheme">
				<xsl:with-param name="scheme" select="substring-before($uri, ':')" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="starts-with($uri, '/') or ($uri-has-scheme = 'true')" />
	</xsl:template>

	<xsl:template name="is-valid-scheme">
		<xsl:param name="scheme" />

		<xsl:variable name="alpha">
			<xsl:text>ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:text>
			<xsl:text>abcdefghijklmnopqrstuvwxyz</xsl:text>
		</xsl:variable>
		<xsl:variable name="following-chars">
			<xsl:value-of select="$alpha" />
			<xsl:text>0123456789</xsl:text>
			<xsl:text>+-.</xsl:text>
		</xsl:variable>

		<xsl:value-of
			select="
				$scheme
				and not(translate(substring($scheme, 1, 1), $alpha, ''))
				and not(translate(substring($scheme, 2), $following-chars, ''))"
		 />
	</xsl:template>
</xsl:stylesheet>