module dynamin.c.portaudio;

/*
 * A complete binding to the core of the PortAudio library v19.
 */

version(build) { pragma(link, portaudio); }

extern(C):

int Pa_GetVersion();

char* Pa_GetVersionText();

alias int PaError;

alias int PaErrorCode;
enum : PaErrorCode {
	paNoError = 0,

	paNotInitialized = -10000,
	paUnanticipatedHostError,
	paInvalidChannelCount,
	paInvalidSampleRate,
	paInvalidDevice,
	paInvalidFlag,
	paSampleFormatNotSupported,
	paBadIODeviceCombination,
	paInsufficientMemory,
	paBufferTooBig,
	paBufferTooSmall,
	paNullCallback,
	paBadStreamPtr,
	paTimedOut,
	paInternalError,
	paDeviceUnavailable,
	paIncompatibleHostApiSpecificStreamInfo,
	paStreamIsStopped,
	paStreamIsNotStopped,
	paInputOverflowed,
	paOutputUnderflowed,
	paHostApiNotFound,
	paInvalidHostApi,
	paCanNotReadFromACallbackStream,
	paCanNotWriteToACallbackStream,
	paCanNotReadFromAnOutputOnlyStream,
	paCanNotWriteToAnInputOnlyStream,
	paIncompatibleStreamHostApi,
	paBadBufferPtr
}

char* Pa_GetErrorText(PaError errorCode);

PaError Pa_Initialize();

PaError Pa_Terminate();

alias int PaDeviceIndex;

enum : PaDeviceIndex {
	paNoDevice = -1,
	paUseHostApiSpecificDeviceSpecification  = -2
}

alias int PaHostApiIndex;

PaHostApiIndex Pa_GetHostApiCount();

PaHostApiIndex Pa_GetDefaultHostApi();

alias int PaHostApiTypeId;
enum : PaHostApiTypeId {
	paInDevelopment = 0,
	paDirectSound = 1,
	paMME = 2,
	paASIO = 3,
	paSoundManager = 4,
	paCoreAudio = 5,
	paOSS = 7,
	paALSA = 8,
	paAL = 9,
	paBeOS = 10,
	paWDMKS = 11,
	paJACK = 12,
	paWASAPI = 13,
	paAudioScienceHPI = 14
}

struct PaHostApiInfo {
	int structVersion;
	PaHostApiTypeId type;
	char* name;

	int deviceCount;

	PaDeviceIndex defaultInputDevice;

	PaDeviceIndex defaultOutputDevice;

}

PaHostApiInfo* Pa_GetHostApiInfo(PaHostApiIndex hostApi);

PaHostApiIndex Pa_HostApiTypeIdToHostApiIndex(PaHostApiTypeId type);

PaDeviceIndex Pa_HostApiDeviceIndexToDeviceIndex(
	PaHostApiIndex hostApi,
	int hostApiDeviceIndex);

struct PaHostErrorInfo {
	PaHostApiTypeId hostApiType;
	int errorCode;
	char* errorText;
}


PaHostErrorInfo* Pa_GetLastHostErrorInfo();

PaDeviceIndex Pa_GetDeviceCount();

PaDeviceIndex Pa_GetDefaultInputDevice();

PaDeviceIndex Pa_GetDefaultOutputDevice();

alias double PaTime;

alias uint PaSampleFormat;

enum : PaSampleFormat {
	paFloat32        = 0x00000001,
	paInt32          = 0x00000002,
	paInt24          = 0x00000004,
	paInt16          = 0x00000008,
	paInt8           = 0x00000010,
	paUInt8          = 0x00000020,
	paCustomFormat   = 0x00010000,

	paNonInterleaved = 0x80000000
}

struct PaDeviceInfo {
	int structVersion;
	char* name;
	PaHostApiIndex hostApi;

	int maxInputChannels;
	int maxOutputChannels;

	PaTime defaultLowInputLatency;
	PaTime defaultLowOutputLatency;
	PaTime defaultHighInputLatency;
	PaTime defaultHighOutputLatency;

	double defaultSampleRate;
}

PaDeviceInfo* Pa_GetDeviceInfo(PaDeviceIndex device);

struct PaStreamParameters {
	PaDeviceIndex device;

	int channelCount;

	PaSampleFormat sampleFormat;

	PaTime suggestedLatency;

	void* hostApiSpecificStreamInfo;
}

const paFormatIsSupported = 0;

PaError Pa_IsFormatSupported(
	PaStreamParameters* inputParameters,
	PaStreamParameters* outputParameters,
	double sampleRate);

alias void PaStream;

const paFramesPerBufferUnspecified = 0;

alias uint PaStreamFlags;
enum : PaStreamFlags {
	paNoFlag                = 0,
	paClipOff               = 0x00000001,
	paDitherOff             = 0x00000002,
	paNeverDropInput        = 0x00000004,
	paPrimeOutputBuffersUsingStreamCallback = 0x00000008,
	paPlatformSpecificFlags = 0xFFFF0000
}

struct PaStreamCallbackTimeInfo {
	PaTime inputBufferAdcTime;
	PaTime currentTime;
	PaTime outputBufferDacTime;
}

alias uint PaStreamCallbackFlags;
enum : PaStreamCallbackFlags {
	paInputUnderflow  = 0x00000001,
	paInputOverflow   = 0x00000002,
	paOutputUnderflow = 0x00000004,
	paOutputOverflow  = 0x00000008,
	paPrimingOutput   = 0x00000010
}

alias uint PaStreamCallbackResult;
enum : PaStreamCallbackResult {
	paContinue = 0,
	paComplete = 1,
	paAbort = 2
}

alias int function(
	void* input, void* output,
	uint frameCount,
	PaStreamCallbackTimeInfo* timeInfo,
	PaStreamCallbackFlags statusFlags,
	void* userData) PaStreamCallback;

PaError Pa_OpenStream(
	PaStream** stream,
	PaStreamParameters* inputParameters,
	PaStreamParameters* outputParameters,
	double sampleRate,
	uint framesPerBuffer,
	PaStreamFlags streamFlags,
	PaStreamCallback streamCallback,
	void* userData);

PaError Pa_OpenDefaultStream(
	PaStream** stream,
	int numInputChannels,
	int numOutputChannels,
	PaSampleFormat sampleFormat,
	double sampleRate,
	uint framesPerBuffer,
	PaStreamCallback streamCallback,
	void* userData);

PaError Pa_CloseStream(PaStream* stream);

alias void function(void* userData) PaStreamFinishedCallback;

PaError Pa_SetStreamFinishedCallback(
	PaStream* stream, PaStreamFinishedCallback streamFinishedCallback);

PaError Pa_StartStream(PaStream* stream);

PaError Pa_StopStream(PaStream* stream);

PaError Pa_AbortStream(PaStream* stream);

PaError Pa_IsStreamStopped(PaStream* stream);

PaError Pa_IsStreamActive(PaStream* stream);

struct PaStreamInfo {
	int structVersion;

	PaTime inputLatency;

	PaTime outputLatency;

	double sampleRate;
}

PaStreamInfo* Pa_GetStreamInfo(PaStream* stream);

PaTime Pa_GetStreamTime(PaStream* stream);

double Pa_GetStreamCpuLoad(PaStream* stream);

PaError Pa_ReadStream(
	PaStream* stream,
	void* buffer,
	uint frames);


PaError Pa_WriteStream(
	PaStream* stream,
	void* buffer,
	uint frames);

int Pa_GetStreamReadAvailable(PaStream* stream);

int Pa_GetStreamWriteAvailable(PaStream* stream);

PaError Pa_GetSampleSize(PaSampleFormat format);

void Pa_Sleep(long msec);

