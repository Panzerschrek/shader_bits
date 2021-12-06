const float c_two_pi= 2.0 * 3.1415926535;

const float c_beat_period= 64.0;
const float c_beat_fraction= 1.0 / 8.0;
const int c_start_beat= 2;
const int c_end_beat= 9;

const float c_base_freq= 220.0;
const float c_sample_scale= 0.333 / float(1 + c_end_beat - c_start_beat);

vec2 mainSound(int samp, float time)
{
	float w= time * c_base_freq;
	float p= w * c_two_pi;
	float base_wave= sin(p) + sin(p * 2.0) * 0.5;

	float result= base_wave;

	// See https://www.youtube.com/watch?v=Qyn64b4LNJ0.
	for(int beat_n= c_start_beat; beat_n <= c_end_beat; ++beat_n)
	{
		float current_period= c_beat_period * float(beat_n);
		float beat_factor= mod(w, current_period);
		if(beat_factor < current_period * c_beat_fraction)
		{
			float beat_p= 4.0 * p / float(beat_n);
			result+= sin(beat_p) + sin(beat_p * 2.0) * 0.5 + sin(beat_p * 3.0) * 0.3333;
		}
	}

	return vec2(result * c_sample_scale);
}