def main():
	
	num = 6
	if(num>0):
		print("El número es positivo.\n")
		
	elif(num==0):
		print("El número es cero.\n")
		
	else:
		print("El número es negativo.\n")
		
	if(num>=0 and num<=9):
		print("El valor tiene un digito.\n")
		
	else:
		print("El valor tiene mas de un digito.\n")
		
	return 0
	
if __name__ == '__main__':
	main()
