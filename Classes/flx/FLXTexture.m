#import "FLXTexture.h"

static unsigned int nextPOT(unsigned int x)
{
    x = x - 1;
    x = x | (x >> 1);
    x = x | (x >> 2);
    x = x | (x >> 4);
    x = x | (x >> 8);
    x = x | (x >>16);
    return x + 1;
}

@implementation FLXTexture

- (void)setupWithBitmap:(const void*)data {
	glGenTextures(1, &_name);
	glBindTexture(GL_TEXTURE_2D, _name);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _textureWidth, _textureHeight, 0, 
				 GL_RGBA, GL_UNSIGNED_BYTE, data);
}

- (id)initWithCGImage:(CGImageRef)image {
	if ((self = [super init])) {
		_contentsWidth = CGImageGetWidth(image);
		_contentsHeight = CGImageGetHeight(image);
		_textureWidth = nextPOT(_contentsWidth);
		_textureHeight = nextPOT(_contentsHeight);
		
		int rowBytes = CGImageGetBytesPerRow(image);

		CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(image));
		GLubyte *pixels = (GLubyte *)CFDataGetBytePtr(data);
		
		if (_contentsWidth != _textureWidth || 
			_contentsHeight != _textureHeight) {
			int dstBytes = _textureWidth*4;
			GLubyte *temp = (GLubyte *)malloc(dstBytes * _textureHeight);
			for (int y = 0; y < _contentsHeight; y++) {
				memcpy(&temp[y*dstBytes], &pixels[y*rowBytes], rowBytes);
			}
			pixels = temp;
			rowBytes = dstBytes;
		}
		
		[self setupWithBitmap:pixels];
		CFRelease(data);
	}
	return self;
}

- (void)draw:(FLNumber)x :(FLNumber)y {
	GLfloat s = (GLfloat)_contentsWidth / (GLfloat)_textureWidth;
	GLfloat t = (GLfloat)_contentsHeight / (GLfloat)_textureHeight;
	
	GLfloat	coordinates[] = { 
		0.0f,	t,
		s,		t,
		0.0f,	0.0f,
		s,		0.0f,
	};
	
	GLfloat	width = (GLfloat)_contentsWidth;
	GLfloat height = (GLfloat)_contentsHeight;
	
	GLfloat	vertices[] = {	
		x,			y,				0.0f,
		width + x,	y,				0.0f,
		x,			height  + y,	0.0f,
		width + x,	height  + y,	0.0f,
	};
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)dealloc {
	if(_name) {
		glDeleteTextures(1, &_name);
	}
	[super dealloc];
}


@end
