def main():
	
	sum = 0
	for i in range(1,101):		
		sum += sum+i
		
	print("%d " % (sum))
	return 0
	
if __name__ == '__main__':
	main()
