namespace Gradient {
  open Microsoft.Quantum.Canon;
  open Microsoft.Quantum.Intrinsic;
  open Microsoft.Quantum.Math;
  open Microsoft.Quantum.Convert;
  open Microsoft.Quantum.Measurement;
  open Microsoft.Quantum.Arrays;

  operation qprog(PARAMETERS: Double[]): (Result[], Double[]) {
    let t1 = PARAMETERS[0];
    let t2 = PARAMETERS[1];
    let n = PARAMETERS[2];
    use qubits = Qubit[6] {
      let c1 = qubits[0];
      let c2 = qubits[1];
      let v1 = qubits[2];
      let v2 = qubits[3];
      let u1 = qubits[4];
      let u2 = qubits[5];
      mutable c = 0.;
      repeat {}
      until (not (M(c1) == Zero))
      fixup {
        if (M(c1) == One) { X(c1);}
        if (M(c2) == One) { X(c2);}
        if (M(v1) == One) { X(v1);}
        if (M(v2) == One) { X(v2);}
        if (M(u1) == One) { X(u1);}
        if (M(u2) == One) { X(u2);}
        H(v1);
        H(v2);
        H(u1);
        H(u2);
        X(c1);
        X(c2);
        Controlled Z([u1,u2,v1,v2,c1], c2);
        Controlled Z([c1], c2);
        X(c2);
        X(c1);
        H(c1);
        H(c2);
        Controlled X([c1,u2], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        X(c1);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1,u2], u1);
        X(c1);
        Controlled X([c2,v2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        X(c2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2,v2], v1);
        X(c2);
        Rx(t1, c1);
        Rx(t2, c2);
        H(c1);
        H(c2);
        X(c1);
        X(c2);
        Controlled Z([c1,c2,u1,u2,v1], v2);
        Controlled Z([c1], c2);
        X(c2);
        X(c1);
        H(c1);
        H(c2);
        Controlled X([c1,u2], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        X(c1);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1,u2], u1);
        X(c1);
        Controlled X([c2,v2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        X(c2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2,v2], v1);
        X(c2);
        if ((c < n)) {
          set c += 1.;
        } else {
          
        }
        if (M(c1) == One) { X(c1);}
        Controlled X([u1,u2,v1,v2], c1);
      }
      let all_result = MultiM(qubits);
      ResetAll(qubits);
      let all_count = [c];
      return (all_result, all_count);
    }
  }
  
  operation sample_qprog(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double {
    mutable sum = 0.;
    for j in 1..SAMPLE_NUM {
      let (temp, c) = qprog(PARAMETERS);
      set sum += c[0] * OBSERVABLE[ResultArrayAsInt(temp)];
    }
    return sum / IntAsDouble(SAMPLE_NUM);
  }
  
  operation sample2_qprog(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double {
    mutable sum = 0.;
    for j in 1..SAMPLE_NUM {
      let (temp, c) = qprog(PARAMETERS);
      set sum += c[0] * c[0] * OBSERVABLE[ResultArrayAsInt(temp)];
    }
    return sum / IntAsDouble(SAMPLE_NUM);
  }

  operation pdqprog_t1(PARAMETERS: Double[]): (Result[], Double[], Double) {
    let t1 = PARAMETERS[0];
    let t2 = PARAMETERS[1];
    let n = PARAMETERS[2];
    use qubits = Qubit[8] {
      let c1 = qubits[0];
      let c2 = qubits[1];
      let v1 = qubits[2];
      let v2 = qubits[3];
      let u1 = qubits[4];
      let u2 = qubits[5];
      let t1_q1 = qubits[6];
      let t1_q2 = qubits[7];
      mutable c = 0.;
      if (M(t1_q1) == One) { X(t1_q1);}
      if (M(t1_q2) == One) { X(t1_q2);}
      mutable t1_flag = 1.;
      mutable t1_c = 1.;
      mutable t1_ps = 0.;
      let t1_s = 2.488516;
      let t1_m = 0.250000;
      mutable t1_a = 2. * ArcSin(Sqrt(1. / (t1_s - t1_ps) / t1_c / PowD(Log(t1_c+E()), 1.+t1_m)));
      Ry(t1_a, t1_q2);
      repeat {}
      until (not (M(c1) == Zero))
      fixup {
        if (M(c1) == One) { X(c1);}
        if (M(c2) == One) { X(c2);}
        if (M(v1) == One) { X(v1);}
        if (M(v2) == One) { X(v2);}
        if (M(u1) == One) { X(u1);}
        if (M(u2) == One) { X(u2);}
        H(v1);
        H(v2);
        H(u1);
        H(u2);
        X(c1);
        X(c2);
        Controlled Z([u1,u2,v1,v2,c1], c2);
        Controlled Z([c1], c2);
        X(c2);
        X(c1);
        H(c1);
        H(c2);
        Controlled X([c1,u2], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        X(c1);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1,u2], u1);
        X(c1);
        Controlled X([c2,v2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        X(c2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2,v2], v1);
        X(c2);
        if (M(t1_q1) == Zero) {
          if (M(t1_q2) == Zero) {
            set t1_ps += 1. / t1_c / PowD(Log(t1_c+E()), 1.+t1_m);
            set t1_c += 1.;
            set t1_a = 2. * ArcSin(Sqrt(1. / (t1_s - t1_ps) / t1_c / PowD(Log(t1_c+E()), 1.+t1_m)));
            Ry(t1_a, t1_q2);
          } else {
            X(t1_q1);
            H(t1_q2);
            if (M(t1_q2) == Zero) { Rx(PI() / 2., c1);}
            else { Rx(-PI() / 2., c1); set t1_flag = -1.;}
          }
        }
        Rx(t1, c1);
        Rx(t2, c2);
        H(c1);
        H(c2);
        X(c1);
        X(c2);
        Controlled Z([c1,c2,u1,u2,v1], v2);
        Controlled Z([c1], c2);
        X(c2);
        X(c1);
        H(c1);
        H(c2);
        Controlled X([c1,u2], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        X(c1);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1,u2], u1);
        X(c1);
        Controlled X([c2,v2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        X(c2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2,v2], v1);
        X(c2);
        if ((c < n)) {
          set c += 1.;
        } else {
          
        }
        if (M(c1) == One) { X(c1);}
        Controlled X([u1,u2,v1,v2], c1);
      }
      let result_t1_q1 = M(t1_q1);
      let all_result = MultiM(qubits[...5]);
      ResetAll(qubits);
      let all_count = [c];
      if (result_t1_q1 == One) {
        return (all_result, all_count, t1_flag * t1_c * PowD(Log(t1_c+E()), 1.+t1_m) * t1_s);
      } else {
        return (all_result, all_count, 0.);
      }
    }
  }
  
  operation sample_pdqprog_t1(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double {
    mutable sum = 0.;
    for j in 1..SAMPLE_NUM {
      let (temp, c, frac) = pdqprog_t1(PARAMETERS);
      set sum += c[0] * frac * OBSERVABLE[ResultArrayAsInt(temp)];
    }
    return sum / IntAsDouble(SAMPLE_NUM);
  }

  operation pdqprog_t2(PARAMETERS: Double[]): (Result[], Double[], Double) {
    let t1 = PARAMETERS[0];
    let t2 = PARAMETERS[1];
    let n = PARAMETERS[2];
    use qubits = Qubit[8] {
      let c1 = qubits[0];
      let c2 = qubits[1];
      let v1 = qubits[2];
      let v2 = qubits[3];
      let u1 = qubits[4];
      let u2 = qubits[5];
      let t2_q1 = qubits[6];
      let t2_q2 = qubits[7];
      mutable c = 0.;
      if (M(t2_q1) == One) { X(t2_q1);}
      if (M(t2_q2) == One) { X(t2_q2);}
      mutable t2_flag = 1.;
      mutable t2_c = 1.;
      mutable t2_ps = 0.;
      let t2_s = 2.488516;
      let t2_m = 0.250000;
      mutable t2_a = 2. * ArcSin(Sqrt(1. / (t2_s - t2_ps) / t2_c / PowD(Log(t2_c+E()), 1.+t2_m)));
      Ry(t2_a, t2_q2);
      repeat {}
      until (not (M(c1) == Zero))
      fixup {
        if (M(c1) == One) { X(c1);}
        if (M(c2) == One) { X(c2);}
        if (M(v1) == One) { X(v1);}
        if (M(v2) == One) { X(v2);}
        if (M(u1) == One) { X(u1);}
        if (M(u2) == One) { X(u2);}
        H(v1);
        H(v2);
        H(u1);
        H(u2);
        X(c1);
        X(c2);
        Controlled Z([u1,u2,v1,v2,c1], c2);
        Controlled Z([c1], c2);
        X(c2);
        X(c1);
        H(c1);
        H(c2);
        Controlled X([c1,u2], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        X(c1);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1,u2], u1);
        X(c1);
        Controlled X([c2,v2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        X(c2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2,v2], v1);
        X(c2);
        Rx(t1, c1);
        if (M(t2_q1) == Zero) {
          if (M(t2_q2) == Zero) {
            set t2_ps += 1. / t2_c / PowD(Log(t2_c+E()), 1.+t2_m);
            set t2_c += 1.;
            set t2_a = 2. * ArcSin(Sqrt(1. / (t2_s - t2_ps) / t2_c / PowD(Log(t2_c+E()), 1.+t2_m)));
            Ry(t2_a, t2_q2);
          } else {
            X(t2_q1);
            H(t2_q2);
            if (M(t2_q2) == Zero) { Rx(PI() / 2., c2);}
            else { Rx(-PI() / 2., c2); set t2_flag = -1.;}
          }
        }
        Rx(t2, c2);
        H(c1);
        H(c2);
        X(c1);
        X(c2);
        Controlled Z([c1,c2,u1,u2,v1], v2);
        Controlled Z([c1], c2);
        X(c2);
        X(c1);
        H(c1);
        H(c2);
        Controlled X([c1,u2], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        X(c1);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1], u1);
        Controlled X([c1,u1], u2);
        Controlled X([c1,u2], u1);
        X(c1);
        Controlled X([c2,v2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        X(c2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2], v1);
        Controlled X([c2,v1], v2);
        Controlled X([c2,v2], v1);
        X(c2);
        if ((c < n)) {
          set c += 1.;
        } else {
          
        }
        if (M(c1) == One) { X(c1);}
        Controlled X([u1,u2,v1,v2], c1);
      }
      let result_t2_q1 = M(t2_q1);
      let all_result = MultiM(qubits[...5]);
      ResetAll(qubits);
      let all_count = [c];
      if (result_t2_q1 == One) {
        return (all_result, all_count, t2_flag * t2_c * PowD(Log(t2_c+E()), 1.+t2_m) * t2_s);
      } else {
        return (all_result, all_count, 0.);
      }
    }
  }
  
  operation sample_pdqprog_t2(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double {
    mutable sum = 0.;
    for j in 1..SAMPLE_NUM {
      let (temp, c, frac) = pdqprog_t2(PARAMETERS);
      set sum += c[0] * frac * OBSERVABLE[ResultArrayAsInt(temp)];
    }
    return sum / IntAsDouble(SAMPLE_NUM);
  }

  operation gradient_qprog(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double[] {
    mutable g = new Double[3];
    set g w/= 0 <- sample_pdqprog_t1(SAMPLE_NUM, PARAMETERS, OBSERVABLE);
    set g w/= 1 <- sample_pdqprog_t2(SAMPLE_NUM, PARAMETERS, OBSERVABLE);
    for j in 2..2 {
      set g w/= j <- 0.;
    }
    return g;
  }
}
