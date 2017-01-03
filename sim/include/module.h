#ifndef MODULE_H
#define MODULE_H

class Module {
	public:
		virtual void write(unsigned short addr, unsigned char data) {
			return;
		}

		virtual unsigned char read(unsigned short addr) {
			return 0xff;
		}
};


#endif
