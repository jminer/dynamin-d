module dynamin.c.vorbisfile;

/*
 * A binding to the vorbisfile API.
 */

version(build) { pragma(link, vorbisfile); }

extern(C):

alias long ogg_int64_t;

// ogg.h

struct oggpack_buffer {
	int  endbyte;
	int  endbit;

	byte* buffer;
	byte* ptr;
	int   storage;
} ;

struct ogg_stream_state {
	byte   *body_data;
	int    body_storage;
	int    body_fill;
	int    body_returned;


	int     *lacing_vals;
	ogg_int64_t *granule_vals;
	int    lacing_storage;
	int    lacing_fill;
	int    lacing_packet;
	int    lacing_returned;

	byte    header[282];
	int              header_fill;

	int     e_o_s;
	int     b_o_s;
	int    serialno;
	int    pageno;
	ogg_int64_t  packetno;
	ogg_int64_t   granulepos;
}

struct ogg_sync_state {
	byte* data;
	int   storage;
	int   fill;
	int   returned;

	int   unsynced;
	int   headerbytes;
	int   bodybytes;
}

// codec.h

struct vorbis_info {
	int vers;
	int channels;
	int rate;

	int bitrate_upper;
	int bitrate_nominal;
	int bitrate_lower;
	int bitrate_window;

	void* codec_setup;
}

struct vorbis_dsp_state {
	int analysisp;
	vorbis_info* vi;

	float** pcm;
	float** pcmret;
	int     pcm_storage;
	int     pcm_current;
	int     pcm_returned;

	int preextrapolate;
	int eofflag;

	int lW;
	int W;
	int nW;
	int centerW;

	ogg_int64_t granulepos;
	ogg_int64_t sequence;

	ogg_int64_t glue_bits;
	ogg_int64_t time_bits;
	ogg_int64_t floor_bits;
	ogg_int64_t res_bits;

	void* backend_state;
}

struct vorbis_block {
  float** pcm;
  oggpack_buffer opb;

  int lW;
  int W;
  int nW;
  int pcmend;
  int mode;

  int         eofflag;
  ogg_int64_t granulepos;
  ogg_int64_t sequence;
  vorbis_dsp_state* vd;

  void*        localstore;
  int          localtop;
  int          localalloc;
  int          totaluse;
  alloc_chain* reap;

  int glue_bits;
  int time_bits;
  int floor_bits;
  int res_bits;

  void *internal;
}

struct alloc_chain {
  void* ptr;
  alloc_chain* next;
}

struct vorbis_comment {
	char** user_comments;
	int*   comment_lengths;
	int    comments;
	char*  vendor;
}

enum {
	OV_FALSE = -1,
	OV_EOF   = -2,
	OV_HOLE  = -3
}

enum {
	OV_EREAD      = -128,
	OV_EFAULT     = -129,
	OV_EIMPL      = -130,
	OV_EINVAL     = -131,
	OV_ENOTVORBIS = -132,
	OV_EBADHEADER = -133,
	OV_EVERSION   = -134,
	OV_ENOTAUDIO  = -135,
	OV_EBADPACKET = -136,
	OV_EBADLINK   = -137,
	OV_ENOSEEK    = -138
}

// vorbisfile.h

struct ov_callbacks {
	size_t function(void* ptr, size_t size, size_t nmemb, void* datasource) read_func;
	int function(void* datasource, ogg_int64_t offset, int whence) seek_func;
	int function(void* datasource) close_func;
	int function(void* datasource) tell_func;
}

enum {
	NOTOPEN   = 0,
	PARTOPEN  = 1,
	OPENED    = 2,
	STREAMSET = 3,
	INITSET   = 4
}

struct OggVorbis_File {
	void*            datasource;
	int              seekable;
	ogg_int64_t      offset;
	ogg_int64_t      end;
	ogg_sync_state   oy;

	int              links;
	ogg_int64_t*     offsets;
	ogg_int64_t*     dataoffsets;
	int*             serialnos;
	ogg_int64_t*     pcmlengths;
	vorbis_info*     vi;
	vorbis_comment*  vc;

	ogg_int64_t      pcm_offset;
	int              ready_state;
	int              current_serialno;
	int              current_link;

	double           bittrack;
	double           samptrack;

	ogg_stream_state os;
	vorbis_dsp_state vd;
	vorbis_block     vb;

	ov_callbacks callbacks;
}
import tango.stdc.stdio;
int ov_clear(OggVorbis_File* vf);
int ov_open(FILE* f,OggVorbis_File* vf,char* initial,int ibytes);
int ov_open_callbacks(void* datasource, OggVorbis_File* vf,
		char* initial, int ibytes, ov_callbacks callbacks);

int ov_test(FILE* f,OggVorbis_File* vf,char* initial,int ibytes);
int ov_test_callbacks(void* datasource, OggVorbis_File* vf,
		char* initial, int ibytes, ov_callbacks callbacks);
int ov_test_open(OggVorbis_File* vf);

int ov_bitrate(OggVorbis_File* vf,int i);
int ov_bitrate_instant(OggVorbis_File* vf);
int ov_streams(OggVorbis_File* vf);
int ov_seekable(OggVorbis_File* vf);
int ov_serialnumber(OggVorbis_File* vf,int i);

ogg_int64_t ov_raw_total(OggVorbis_File* vf,int i);
ogg_int64_t ov_pcm_total(OggVorbis_File* vf,int i);
double ov_time_total(OggVorbis_File* vf,int i);

int ov_raw_seek(OggVorbis_File* vf,ogg_int64_t pos);
int ov_pcm_seek(OggVorbis_File* vf,ogg_int64_t pos);
int ov_pcm_seek_page(OggVorbis_File* vf,ogg_int64_t pos);
int ov_time_seek(OggVorbis_File* vf,double pos);
int ov_time_seek_page(OggVorbis_File* vf,double pos);

int ov_raw_seek_lap(OggVorbis_File* vf,ogg_int64_t pos);
int ov_pcm_seek_lap(OggVorbis_File* vf,ogg_int64_t pos);
int ov_pcm_seek_page_lap(OggVorbis_File* vf,ogg_int64_t pos);
int ov_time_seek_lap(OggVorbis_File* vf,double pos);
int ov_time_seek_page_lap(OggVorbis_File* vf,double pos);

ogg_int64_t ov_raw_tell(OggVorbis_File* vf);
ogg_int64_t ov_pcm_tell(OggVorbis_File* vf);
double ov_time_tell(OggVorbis_File* vf);

vorbis_info* ov_info(OggVorbis_File* vf,int link);
vorbis_comment* ov_comment(OggVorbis_File* vf,int link);

int ov_read_float(OggVorbis_File* vf,float*** pcm_channels,int samples,
			  int* bitstream);
int ov_read(OggVorbis_File* vf,char* buffer,int length,
		    int bigendianp,int word,int sgned,int* bitstream);
int ov_crosslap(OggVorbis_File* vf1,OggVorbis_File* vf2);

int ov_halfrate(OggVorbis_File* vf,int flag);
int ov_halfrate_p(OggVorbis_File* vf);

