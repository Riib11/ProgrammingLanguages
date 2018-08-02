# quicksort: This code is contributed by Mohit Kumra

# This function takes last element as pivot, places
# the pivot element at its correct position in sorted
# array, and places all smaller (smaller than pivot)
# to left of pivot and all greater elements to right
# of pivot
def partition( arr , low , high, getval ):
    i = ( low-1 )             # index of smaller element
    pivot = getval(arr[high]) # pivot
 
    for j in range(low , high):
 
        # If current element is smaller than or
        # equal to pivot
        if   getval(arr[j]) <= pivot:
         
            # increment index of smaller element
            i = i+1
            v_i = getval(arr[i])
            v_j = getval(arr[j])
            arr[i] , arr[j] = arr[j] , arr[i]
 
    arr[i+1] , arr[high] = arr[high] , arr[i+1]

    return ( i+1 )
 
# The main function that implements QuickSort
# arr[] --> Array to be sorted,
# low  --> Starting index,
# high  --> Ending index
 
# Function to do Quick sort
def quicksort( arr , getval=lambda x:x , low="None" , high="None" ):
    low = low if "None"!=low else 0
    high = high if "None"!=high else len(arr)-1
    if low < high:
 
        # pi is partitioning index, arr[p] is now
        # at right place
        pi = partition( arr , low , high , getval )
 
        # Separately sort elements before
        # partition and after partition
        quicksort( arr , getval , low  , pi-1 )
        quicksort( arr , getval , pi+1 , high )

if __name__ == "__main__":
    # test
    arr = [10, 7, 8, 9, 1, 5]
    print(arr)
    quicksort(arr)
    print(arr)