#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

#include "pwm.h"

int write_file(const char* path, const char* data);

int start_pwm(const char* path, unsigned long period, unsigned long duty, int polarity) {
	char duty_path[100];
	char period_path[100];
	char polarity_path[100];
	char buf[32];

	//set paths
	snprintf(duty_path, sizeof(duty_path), "%s/duty", path);
	snprintf(period_path, sizeof(period_path), "%s/period", path);
	snprintf(polarity_path, sizeof(polarity_path), "%s/polarity", path);

	//set duty
	snprintf(buf, sizeof(buf), "%lu", duty);
	int res = write_file(duty_path, buf);
	if (res < 0) {
		perror("pwm/duty");
		return res;
	}

	//set period
	snprintf(buf, sizeof(buf), "%lu", period);
	res = write_file(period_path, buf);
	if (res < 0) {
		perror("pwm/period");
		return res;
	}

	//set polarity
	snprintf(buf, sizeof(buf), "%d", polarity);
	res = write_file(polarity_path, buf);
	if (res < 0) {
		perror("pwm/polarity");
		return res;
	}

	return 0;
}

int write_file(const char* path, const char* data) {
	//open
	int file = open(path, O_WRONLY);
	if (file < 0)
		return file;

	//write
	int bytes_to_write = strlen(data);
	int bytes_written = 0;
	while (bytes_to_write > bytes_written) {
		int res = write(file, data, bytes_to_write - bytes_written);
		if (res < 0)
			return res;
		data += res;
		bytes_written += res;
	}

	//close
	return close(file);
}