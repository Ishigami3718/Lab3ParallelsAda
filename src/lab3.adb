with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Producer_Consumer is
   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;


   procedure Starter (Storage_Size : in Integer; Item_Numbers : in Integer; Producers_Count: in Integer; Consumers_Count: in Integer) is
      Storage : List;

      Access_Storage : Counting_Semaphore (1, Default_Ceiling);
      Full_Storage   : Counting_Semaphore (Storage_Size, Default_Ceiling);
      Empty_Storage  : Counting_Semaphore (0, Default_Ceiling);

      task type Producer is
         entry Start (Items : in Integer;Id: in Integer);
         end Producer;

      task type Consumer is
         entry Start(Items: in Integer;Id: in Integer);
         end Consumer;

      Producers : array (1 .. Producers_Count) of Producer;
      Consumers : array (1 .. Consumers_Count) of Consumer;

      task body Producer is

         Item_Numbers : Integer;
         Id: Integer;
      begin
           accept Start (Items : in Integer;Id: in Integer) do
            Producer.Item_Numbers := Items;
            Producer.Id:=Id;
           end Start;

         for i in 1 .. Item_Numbers loop
            Full_Storage.Seize;
            Access_Storage.Seize;

            Storage.Append ("item " & i'Img & "by producer " & Producer.Id'img);
            Put_Line ("producer " & Producer.Id'img & "added item " & i'Img);

            Access_Storage.Release;
            Empty_Storage.Release;
            delay 1.5;
         end loop;

      end Producer;

      task body Consumer is
         Item_Numbers : Integer;
         Id: Integer;
      begin
           accept Start (Items : in Integer;Id: in Integer) do
            Consumer.Item_Numbers := Items;
            Consumer.Id:=Id;
           end Start;

         for i in 1 .. Item_Numbers loop
            Empty_Storage.Seize;
            Access_Storage.Seize;

            declare
               item : String := First_Element (Storage);
            begin
               Put_Line ("consumer" & Consumer.Id'img & "took " & item);
            end;

            Storage.Delete_First;

            Access_Storage.Release;
            Full_Storage.Release;

            delay 2.0;
         end loop;

      end Consumer;
stepProd: Integer := Item_Numbers/Producers_Count;
      remainderProd: Integer := Item_Numbers rem Producers_Count;
      stepCon: Integer := Item_Numbers/Consumers_Count;
      remainderCon: Integer := Item_Numbers rem Consumers_Count;
   begin

      for i in 1..Producers_Count loop
         if remainderProd>0 then Producers(i).Start(stepProd+1,i);
      else Producers(i).Start(stepProd,i);
      end if;
      remainderProd:=remainderProd-1;

   end loop;

      for i in 1..Consumers_Count loop
      if remainderCon>0 then Consumers(i).Start(stepCon+1,1);
      else Consumers(i).Start(stepCon,i);
         end if;
         remainderCon:=remainderCon-1;
   end loop;
   end Starter;

begin
   Starter (3, 10,2,3);
end Producer_Consumer;
