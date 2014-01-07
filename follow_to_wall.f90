! program to follow one point until it hits the wall

program follow_to_wall
  
  use coil_module
  use points_module
  use vessel_module


  real,dimension(3) :: p
  integer :: i,j,isin, inside_vessel
  real :: dphi

  ! first load the coils
  call allocate_main(6,14)
  call allocate_aux('aux_c.dat')
  call read_coils()

  ! put current in main coils
  do i = 1,main_count
     main_current(i) = -150105./14
  enddo

  do i = 1,aux_count
     aux_current(i) = -150105*0.00000
  enddo

  ! load the vessel
  vessel_file = 'vessel.txt'
  call allocate_vessel()
  call load_vessel()

  ! get the points
  call get_points()

  !file to write output
  open (unit=1,file='results.out',status='unknown')
  !write (1,'(3(F9.6,2X))') p(1:3)

  

  do i=1,n_iter
     if (i == 1) then
        points_move(:,:) = points_start(:,:)
     endif
     do j=1,points_number
        ! Skip points that already hit
        if (points_hit(j) == 1) then
           cycle
        endif
      
        ! check if the last move left us inside the vessel
        p = points_move(j,:)
        isin = inside_vessel(p(1),p(2),p(3),vessel,vessel_size)
        if (isin == 0) then
           ! Set point to hit
           points_hit(j) = 1
           cycle        
        endif
        
        ! for some reason i can't understand removing this
        ! print statement causes the field line follower
        ! to fail.  I need to track this down, but it's
        ! hard to debug without a print statement!
        print *,points_move(j,:)
        ! set the current point
        current_point = j
        call follow_field(points_move(j,:), points_dphi)
        
     
        ! write the new point
        !write (1,'(3(F9.6,2X))') p(1:3)
     enddo
  enddo

  do j=1,points_number
     write (1,*) 'point number',j
     write (1,'(A,3(F9.6,2X))') 'start: ',points_start(j,:)
     write (1,'(A,3(F9.6,2X))') 'end:   ',points_move(j,:)
     write (1,*) 'hit wall:',points_hit(j)
     write (1,*) '------------------'
  enddo

  call dealloc_points()
  call deallocate_coils()


end program follow_to_wall