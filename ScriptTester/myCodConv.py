import sys
import os
import csv

csv_filename = "ConvCodingEx.csv";
currentPath = os.getcwd();
csv_file_path = currentPath + "\\" + csv_filename;
field_names = ['x','ShiftRegA','ShiftRegC','Ak','Ck'];
csv_data_list = [];

dimA = 5;		# dimensione shift register A
A = 0;			# Shift register A

pos_GA0 = 4;		# indice nel generator vector da settare dal LSB
pos_GA3 = 1;		# indice nel generator vector da settare dal LSB
pos_GA4 = 0;		# indice nel generator vector da settare dal LSB

# composizione del Generator Vector
VectorGeneratorA = 2**(pos_GA0);
VectorGeneratorA = VectorGeneratorA | 2**(pos_GA3);
VectorGeneratorA = VectorGeneratorA | 2**(pos_GA4);

dimC = 11;		# dimensione shift register C
C = 0;			# Shift Register C

pos_GC8 = 2;		# indice nel generator vector da settare dal LSB
pos_GC10 = 0;		# indice nel generator vector da settare dal LSB

# composizione del Generator Vector
VectorGeneratorC = 2**(pos_GC8);
VectorGeneratorC = VectorGeneratorC | 2**(pos_GC10);

# struttura dati per comporre la lista da salvare in csv
class data:
	x=0;	# input bit
	A=0;	# stato shift register A
	C=0;	# stato shift register C
	ak=0;	# output bit ak
	ck=0;	# output bit ck

def WriteListToCSV():
	try:
		with open(csv_file_path, 'w', newline='') as csv_file:
			writer = csv.DictWriter(csv_file, fieldnames=field_names);
			writer.writeheader();
			for d in csv_data_list:
				writer.writerow({'x':d.x,'ShiftRegA':'{0:05b}'.format(d.A),'ShiftRegC':'{0:010b}'.format(d.C),'Ak':d.ak,'Ck':d.ck});
		print("List Stored in " + csv_file_path);
	except IOError:
		print("Error opening the file, maybe another process are working on it, close this process and try again");

def code_generator(inputBit):
	global A, C;
	ak = inputBit;

	A = A >> 1;		# shift a destra dello Shift Register A
	C = C >> 1;		# shift a destra dello Shift Register C

	A = A | (ak << (dimA-1));	# inserisco input bit nello Shift Register A

# Xor N to 1 di dei bit da considerare nello Shift Register A
	if bin(A & VectorGeneratorA).count("1")%2 == 0:		# verifico se ho un numero pari di bit
		outA = 0;
	else :
		outA = 1;

# Xor N to 1 di dei bit da considerare nello Shift Register C
	if bin(C & VectorGeneratorC).count("1")%2 == 0:		# verifico se ho un numero pari di bit
		outC = 0;
	else :
		outC = 1;

	ck = outA ^ outC;			# output bit

# salva stato nella lista da salvare in CSV
	d = data();
	d.x = inputBit;
	d.ak = ak;
	d.ck = ck;
	d.A = A;
	d.C = C;
	csv_data_list.append(d);
###########################################

#calcola nuovo stato di C, lo faccio dopo averne utilizzato e salvato lo stato (delay)
	C = C | (ck << (dimC-1));	# inserisco ck nello Shift Register C

	print("-----------------------------------");
	print("x: " + str(d.x));
	print("Shift Register A: " + '{0:05b}'.format(d.A));
	print("Shift Register C: " + '{0:010b}'.format(d.C));
	print("a_k: " + str(d.ak));
	print("c_k: " + str(d.ck));
	
## funzione che esegue Code Generator per il LSB
def InputBit(X):
	x = X & 1;					# bit in ingresso
	code_generator(x);

## funzione che esegue Code Generator per N bit
def InputValue_Nbit(X, cmd):
	Nbit = 0;
	try:
		Nbit = int(cmd[1:]);
	except ValueError:
		print("Wrong number of bits, i'll use 8!")
		Nbit = 8;

	if Nbit == 32:
		print("Input Stream: " + '{0:032b}'.format(X));
		Nbit = 32;
	elif Nbit == 16:
		print("Input Stream: " + '{0:016b}'.format(X));
		Nbit = 16;
	else:
		print("Input Stream: " + '{0:08b}'.format(X));
		Nbit = 8;

	for i in range(0, Nbit):	# eseguo il Code Generator per ogni bit
		InputBit(X);
		X = X >> 1;				# shift dei bit che devo ancora trasmettere

## funzione che gestisce il menu comandi
def commander(cmd):
	global A, C;
	val = 0;
	if (cmd[0] == 'I' or cmd[0] == 'i'):
		print("Insert a number: ");
		try:
			val = int(input());
		except ValueError:
			print("That's not a number!")
			return;
		InputValue_Nbit(val, cmd);

	elif (cmd == 'B' or cmd == 'b'):
		print("Insert a Bit value: ");
		try:
			val = int(input());
		except ValueError:
			print("That's not a number!")
			return;
		InputBit(val);

	elif (cmd == 'S' or cmd == 's'):
		WriteListToCSV();

	elif (cmd == 'D' or cmd == 'd'):
		del csv_data_list[:];
		A = 0;
		C = 0;
		print("Shift Register A: " + '{0:05b}'.format(A));
		print("Shift Register C: " + '{0:010b}'.format(C));
		print("List deleted!");

	elif (cmd == 'Q' or cmd == 'q'):
		sys.exit(0);

	else:
		print("please insert the correct Command");
	print("-----------------------------------");

def main():
	print("Generator Vector for ShiftRegister A: "+'{0:05b}'.format(VectorGeneratorA));
	print("Generator Vector for ShiftRegister B: "+'{0:011b}'.format(VectorGeneratorC));
	while(1):
		print("Chose the command:");
		print("\t->I32, to insert a number(32 bit), the data will be appended in the csv_list");
		print("\t->I16, to insert a number(16 bit), the data will be appended in the csv_list");
		print("\t->I8 (default), to insert a number(8 bit), the data will be appended in the csv_list");
		print("\t->B to insert a bit");
		print("\t->D to Destroy the list and reset the Status of Code Generator");
		print("\t->S to Store the list of data in the csv File, the file will be overwritten");
		print("\t->Q for Quit");
		cmd = input(":");
		commander(cmd);

if __name__ == "__main__":
	main();